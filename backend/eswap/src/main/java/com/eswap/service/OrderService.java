package com.eswap.service;

import com.eswap.common.constants.*;
import com.eswap.common.exception.AlreadyExistsException;
import com.eswap.common.exception.OperationNotPermittedException;
import com.eswap.common.exception.OtpLimitExceededException;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.model.Order;
import com.eswap.model.Post;
import com.eswap.model.Transaction;
import com.eswap.model.User;
import com.eswap.repository.OrderRepository;
import com.eswap.repository.PostRepository;
import com.eswap.repository.TransactionRepository;
import com.eswap.repository.UserRepository;
import com.eswap.response.OrderCounterResponse;
import com.eswap.response.OrderCreationResponse;
import com.eswap.response.OrderResponse;
import com.eswap.service.notification.NotificationService;
import com.eswap.service.payment.CreatePaymentResponse;
import com.eswap.service.payment.PaymentService;
import com.eswap.service.payment.PaymentServiceFactory;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.tomcat.websocket.AuthenticationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {
    private final OrderRepository orderRepository;
    private final TransactionRepository transactionRepository;
    private final PostRepository postRepository;
    private final PaymentServiceFactory paymentServiceFactory;
    private final PaymentService paymentService;
    private final SimpMessagingTemplate messagingTemplate;
    private final int NUMBER_DEPOSIT_PAYMENTS_LIMIT = 3;
    private final BalanceService balanceService;
    private final NotificationService notificationService;

    /**
     * Người mua có 2 lựa chọn:
     * 1. Muốn đăt cọc (status = AWAITING_DEPOSIT)
     * 2. Chờ người bán xác nhận (status = PENDING)
     *
     * @param connectedUser
     * @param postId
     * @param quantity
     * @param paymentType
     * @return OrderCreationResponse
     */
    public OrderCreationResponse createOrder(Authentication connectedUser, long postId, int quantity, String paymentType) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        User buyer = (User) connectedUser.getPrincipal();
        if (!buyer.isEnabled() || buyer.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        Order checkOrder = orderRepository.findByPostAndBuyerUnprocessed(postId, buyer.getId());
        if (checkOrder != null && (checkOrder.getStatus() == Order.OrderStatus.PENDING || checkOrder.getStatus() == Order.OrderStatus.AWAITING_DEPOSIT))
            throw new AlreadyExistsException(AppErrorCode.ORDER_EXISTS);

        // Validate số lượng
        if (quantity <= 0 || quantity > post.getQuantity() - post.getSold()) {
            throw new IllegalArgumentException("Invalid quantity");
        }
        // Tổng tiền
        BigDecimal totalAmount = post.getSalePrice().multiply(BigDecimal.valueOf(quantity));
        String orderId = "ORDER-" + UUID.randomUUID();
        // Nếu chọn đặt cọc
        if (paymentType != null && !paymentType.isEmpty()) {
            // Kiểm tra phương thức thanh toán
            PaymentService service = paymentServiceFactory.getService(paymentType);
            if (service == null) {
                log.error("Loại thanh toán không hỗ trợ: {}", paymentType);
                return null;
            }
            // Tạo đơn hàng với status là AWAITING_DEPOSIT
            BigDecimal depositAmount = calDepositAmount(totalAmount);
            Order order = Order.builder()
                    .id(orderId)
                    .post(post)
                    .buyer(buyer)
                    .seller(post.getUser())
                    .quantity(quantity)
                    .totalAmount(totalAmount)
                    .depositAmount(depositAmount)
                    .remainingAmount(totalAmount.subtract(depositAmount))
                    .numberDepositPayments(1)
                    .paymentTransactionId(orderId)
                    .status(Order.OrderStatus.AWAITING_DEPOSIT)
                    .build();
            order = orderRepository.save(order);
            // Tạo mẫu thanh toán
            CreatePaymentResponse paymentResponse = paymentService.createPaymentQR(order, "");
            OrderResponse orderResponse = OrderResponse.mapperToOrderResponse(order);
            // Real time
            sendOrderWebSocket(order.getBuyer().getUsername(), orderResponse);

            return new OrderCreationResponse(orderResponse, paymentResponse);
        } else {
            // Tạo đơn hàng với status là PENDING
            Order order = Order.builder()
                    .id(orderId)
                    .post(post)
                    .buyer(buyer)
                    .seller(post.getUser())
                    .quantity(quantity)
                    .totalAmount(totalAmount)
                    .depositAmount(BigDecimal.ZERO)
                    .remainingAmount(totalAmount)
                    .status(Order.OrderStatus.PENDING)
                    .build();
            order = orderRepository.save(order);
            OrderResponse orderResponse = OrderResponse.mapperToOrderResponse(order);
            // Real time
            sendOrderWebSocket(order.getBuyer().getUsername(), orderResponse);
            sendOrderWebSocket(order.getSeller().getUsername(), orderResponse);

            User seller = order.getSeller();

            notificationService.createAndPushNotification(
                    buyer.getId(),
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.ORDER,
                    NotificationType.INFORM,
                    "Đơn hàng mới",
                    buyer.getFirstName() + " " + buyer.getLastName() + " đã yêu cầu mua",
                    order.getPost().getId(),
                    order.getId(),
                    seller.getId()
            );
            return new OrderCreationResponse(orderResponse, null);
        }
    }

    // < 300.000 -> 20.000
    // 300 - 1tr -> 50.000
    // > 1tr -> 10%

    /**
     * Tính giá đặt cọc
     * Nếu tổng tiền đơn hàng dưới 300.000đ -> 20.000đ
     * Nếu tổng tiền đơn hàng từ 300.000đ - 1.000.000đ -> 50.000
     * Nếu > 1.000.000đ -> 10% tổng tiền
     *
     * @param amount
     * @return BigDecimal
     */
    public BigDecimal calDepositAmount(BigDecimal amount) {
        if (amount.compareTo(new BigDecimal("300000")) < 0) {
            return new BigDecimal("20000");
        } else if (amount.compareTo(new BigDecimal("1000000")) <= 0) {
            return new BigDecimal("50000");
        } else {
            return amount.multiply(new BigDecimal("0.10")).setScale(0, RoundingMode.DOWN);
        }
    }

    /**
     * Xử lý thanh toán từ dịch vụ thanh toán momo
     *
     * @param orderId
     * @param paymentTransactionId
     */
    public void handleDepositSuccess(String orderId, String paymentTransactionId) {
        Order order = orderRepository.findByPaymentTransactionId(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        // Kiểm tra trạng thái
        if (order.getStatus() != Order.OrderStatus.AWAITING_DEPOSIT) {
            throw new IllegalStateException("Only AWAITING_DEPOSIT orders can be deposited");
        }
        // Giữ chỗ: Cập nhật số lượng đã bán
        Post post = order.getPost();
        post.setSold(post.getSold() + order.getQuantity());
        postRepository.save(post);
        // Lưu transaction
        balanceService.depositTransactionOfBuyer(order, paymentTransactionId);
        // Cập nhật trạng thái order là DEPOSITED
        order.setStatus(Order.OrderStatus.DEPOSITED);
        orderRepository.save(order);
        // Thông báo
        User buyer = order.getBuyer();
        User seller = order.getSeller();
        sendOrderWebSocket(buyer.getUsername(), OrderResponse.mapperToOrderResponse(order));
        sendOrderWebSocket(seller.getUsername(), OrderResponse.mapperToOrderResponse(order));
        notificationService.createAndPushNotification(
                buyer.getId(),
                RecipientType.INDIVIDUAL,
                NotificationCategory.ORDER,
                NotificationType.INFORM,
                "Đơn hàng đã được đặt cọc",
                buyer.getFirstName() + " " + buyer.getLastName() + " đã đặt cọc đơn hàng của bạn",
                order.getPost().getId(),
                order.getId(),
                seller.getId()
        );
    }

    /**
     * Người mua gửi yêu cầu đặt cọc lại cho đơn AWAITING_DEPOSITED. Mỗi đơn hàng được giới hạn số lần đặt cọc lại.
     *
     * @param connectedUser
     * @param orderId
     * @return OrderCreationResponse
     */
    @Transactional
    public OrderCreationResponse deposit(Authentication connectedUser, String orderId, String paymentType) {
        User buyer = (User) connectedUser.getPrincipal();
        if (!buyer.isEnabled() || buyer.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        if (paymentType != null && !paymentType.isEmpty()) {
            PaymentService service = paymentServiceFactory.getService(paymentType);
            if (service == null) {
                log.error("Loại thanh toán không hỗ trợ: {}", paymentType);
                return null;
            }
            Order order = orderRepository.findByIdAndBuyer(orderId, buyer.getId());

            if (order == null) throw new ResourceNotFoundException(AppErrorCode.ORDER_NOT_FOUND, "id", orderId);

            if (order.getStatus() != Order.OrderStatus.AWAITING_DEPOSIT) {
                throw new IllegalStateException("Only AWAITING_DEPOSIT orders can be deposit");
            }
            // Validate số lượng
            if (order.getQuantity() <= 0 || order.getQuantity() > order.getPost().getQuantity() - order.getPost().getSold()) {
                throw new IllegalArgumentException("Invalid quantity");
            }
            // Kiểm tra số lần đặt cọc
            if (order.getNumberDepositPayments() >= NUMBER_DEPOSIT_PAYMENTS_LIMIT) {
                throw new OtpLimitExceededException(AppErrorCode.DEPOSIT_LIMIT_EXCEEDED);
            }
            // Cập nhật số lần đặt cọc
            order.setPaymentTransactionId("ORDER-" + UUID.randomUUID());
            order.setNumberDepositPayments(order.getNumberDepositPayments() + 1);
            order = orderRepository.save(order);
            // Tạo mẫu thanh toán
            CreatePaymentResponse paymentResponse = paymentService.createPaymentQR(order, "");
            OrderResponse orderResponse = OrderResponse.mapperToOrderResponse(order);
            return new OrderCreationResponse(orderResponse, paymentResponse);
        } else {
            throw new ResourceNotFoundException(AppErrorCode.POST_NOT_FOUND, "id", orderId);
        }
    }

    /**
     * Người bán chấp nhận đơn hàng PENDING
     *
     * @param connectedUser
     * @param orderId
     * @return
     */
    public OrderResponse handleSellerAcceptNoDeposit(Authentication connectedUser, String orderId) {
        User seller = (User) connectedUser.getPrincipal();
        if (!seller.isEnabled() || seller.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        Order order = orderRepository.findByIdAndSeller(orderId, seller.getId());

        if (order == null) throw new ResourceNotFoundException(AppErrorCode.ORDER_NOT_FOUND, "id", orderId);
        if (order.getStatus() != Order.OrderStatus.PENDING) {
            throw new IllegalStateException("Only PENDING orders can be deposited");
        }
        // Cập nhật trạng thái order
        order.setDepositAmount(BigDecimal.ZERO);
        order.setRemainingAmount(order.getTotalAmount());
        order.setStatus(Order.OrderStatus.SELLER_ACCEPTS);
        order = orderRepository.save(order);
        OrderResponse response = OrderResponse.mapperToOrderResponse(order);

        // Cập nhật số lượng đã bán
        Post post = order.getPost();
        post.setSold(post.getSold() + order.getQuantity());
        postRepository.save(post);
        // Thông báo
        User buyer = order.getBuyer();
        sendOrderWebSocket(buyer.getUsername(), response);
        sendOrderWebSocket(seller.getUsername(), response);
        notificationService.createAndPushNotification(
                seller.getId(),
                RecipientType.INDIVIDUAL,
                NotificationCategory.ORDER,
                NotificationType.INFORM,
                "Đơn hàng đã được chấp nhận không cần đặt cọc",
                seller.getFirstName() + " " + seller.getLastName() + " đã chấp nhận không cần đặt cọc",
                order.getPost().getId(),
                order.getId(),
                buyer.getId()
        );
        return response;
    }

    /**
     * Hủy đơn hàng
     *
     * @param connected
     * @param orderId
     * @param cancelReasonContent
     * @return
     */
    @Transactional
    public OrderResponse cancelOrder(Authentication connected, String orderId, String cancelReasonContent) {
        User user = (User) connected.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.ORDER_NOT_FOUND, "id", orderId));
        // Kiểm tra trạng thái đơn hàng không phải COMPLETED hoặc không DELETED
        if (order.getStatus() == Order.OrderStatus.COMPLETED && order.getStatus() == Order.OrderStatus.DELETED) {
            throw new IllegalStateException("Completed orders cannot be cancelled");
        }
        Boolean isBuyer;
        if (user.getId() == order.getBuyer().getId()) isBuyer = true;
        else if (user.getId() == order.getSeller().getId()) isBuyer = false;
        else return null;

        // Kiểm tra chỉ cho phép người mua mới hủy đơn đang đợi đặt cọc của họ
        if (!isBuyer && order.getStatus() == Order.OrderStatus.AWAITING_DEPOSIT) {
            throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
        }
        // Trường hợp người mua hủy đơn đợi đặt cọc
        if (order.getStatus() == Order.OrderStatus.AWAITING_DEPOSIT) {
            order.setStatus(Order.OrderStatus.DELETED);
            OrderResponse response = OrderResponse.mapperToOrderResponse(order);
            // Thông báo
            sendOrderWebSocket(order.getBuyer().getUsername(), response);
            return response;
        }
        // Cộng lại số lượng bán ra nếu đơn hàng hiện tại là DEPOSITED hoặc SELLER_ACCEPTS
        if (order.getStatus() == Order.OrderStatus.DEPOSITED || order.getStatus() == Order.OrderStatus.SELLER_ACCEPTS) {
            Post post = order.getPost();
            post.setSold(post.getSold() - order.getQuantity());
            postRepository.save(post);
        }
        // Xử lý tiền đặt cọc
        if (order.getStatus() == Order.OrderStatus.DEPOSITED) {
            if (isBuyer) {
                balanceService.depositReleaseToSeller(order);
            } else {
                balanceService.depositRefundToBuyer(order);
            }
        }
        // Cập nhật status order là CANCELLED
        order.setStatus(Order.OrderStatus.CANCELLED);
        order.setCancelReason(isBuyer ? Order.CancelReason.BUYER_CANCELLED : Order.CancelReason.SELLER_REJECTED);
        order.setCancelReasonContent(cancelReasonContent);
        order = orderRepository.save(order);
        OrderResponse response = OrderResponse.mapperToOrderResponse(order);
        // Thông báo
        User buyer = order.getBuyer();
        User seller = order.getSeller();
        sendOrderWebSocket(buyer.getUsername(), response);
        sendOrderWebSocket(seller.getUsername(), response);
        if (isBuyer) {
            notificationService.createAndPushNotification(
                    buyer.getId(),
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.ORDER,
                    NotificationType.INFORM,
                    "Đơn hàng đã hủy",
                    buyer.getFirstName() + " " + buyer.getLastName() + " đã hủy đơn hàng",
                    order.getPost().getId(),
                    order.getId(),
                    seller.getId()
            );
        } else {
            notificationService.createAndPushNotification(
                    seller.getId(),
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.ORDER,
                    NotificationType.INFORM,
                    "Đơn hàng đã hủy",
                    seller.getFirstName() + " " + seller.getLastName() + " đã hủy đơn hàng",
                    order.getPost().getId(),
                    order.getId(),
                    buyer.getId()
            );
        }
        return response;
    }

    /**
     * Hoàn thành đơn hàng
     * Đối với đơn đặt cọc (DEPOSITED): Chỉ người mua mới được phép hoàn thành đơn hàng
     * Đối với đơn không đặt cọc (SELLER_ACCEPTED): Chỉ người bán mới được phép hoàn thành đơn hàng
     *
     * @param connected
     * @param orderId
     * @return
     */
    @Transactional
    public OrderResponse completeOrder(Authentication connected, String orderId) {
        User user = (User) connected.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        Boolean isBuyer;
        if (user.getId() == order.getBuyer().getId()) isBuyer = true;
        else if (user.getId() == order.getSeller().getId()) isBuyer = false;
        else return null;
        if (isBuyer) {
            // Chỉ cho phép người mua hoàn thành khi đã đặt cọc
            if (order.getStatus() != Order.OrderStatus.DEPOSITED) {
                throw new IllegalStateException("Only DEPOSITED orders can be completed");
            }
            // Cập nhật trạng thái đơn
            order.setStatus(Order.OrderStatus.COMPLETED);
            order = orderRepository.save(order);
            // Xử lý tiền cọc về người bán
            balanceService.depositReleaseToSeller(order);
        } else {
            // Chỉ cho phép người bán hoàn thàng khi order là SELLER_ACCEPTS
            if (order.getStatus() != Order.OrderStatus.SELLER_ACCEPTS) {
                throw new IllegalStateException("Only SELLER_ACCEPTS orders can be completed");
            }
            // Cập nhật trạng thái đơn
            order.setStatus(Order.OrderStatus.COMPLETED);
            order = orderRepository.save(order);
        }
        // Thông báo
        OrderResponse response = OrderResponse.mapperToOrderResponse(order);
        User buyer = order.getBuyer();
        User seller = order.getSeller();
        seller.setReputationScore(seller.getReputationScore() + 1);
        sendOrderWebSocket(buyer.getUsername(), response);
        sendOrderWebSocket(seller.getUsername(), response);
        if (isBuyer) {
            notificationService.createAndPushNotification(
                    buyer.getId(),
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.ORDER,
                    NotificationType.INFORM,
                    "Đơn hàng đã hoàn thành",
                    buyer.getFirstName() + " " + buyer.getLastName() + " đã hoàn thành đơn hàng",
                    order.getPost().getId(),
                    order.getId(),
                    seller.getId()
            );
        } else {
            notificationService.createAndPushNotification(
                    seller.getId(),
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.ORDER,
                    NotificationType.INFORM,
                    "Đơn hàng đã hoàn thành",
                    seller.getFirstName() + " " + seller.getLastName() + " đã hoàn thành đơn hàng",
                    order.getPost().getId(),
                    order.getId(),
                    buyer.getId()
            );
        }
        return response;
    }

    /**
     * Tự động xóa đơn hàng đang đợi thanh toán trong vòng 24h
     */
    @Scheduled(fixedRate = 3600000)
    @Transactional
    @Async
    public void cancelPendingOrdersTimeout() {
        // 1. Lấy danh sách order quá hạn
        List<Order> expiredOrders = orderRepository.findByStatusAndCreatedAtBefore(
                Order.OrderStatus.PENDING,
                LocalDateTime.now().minusHours(24),
                PageRequest.of(0, 100) // Giới hạn batch size
        );

        // 2. Xử lý batch
        expiredOrders.forEach(order -> {
            // 3. Cập nhật trạng thái và lý do
            order.setStatus(Order.OrderStatus.CANCELLED);
            order.setCancelReason(Order.CancelReason.TIMEOUT);
            order.setCancelReasonContent("Tự động hủy do quá thời gian chờ đặt cọc");
            orderRepository.save(order);
            // 4. Gửi thông báo
            User buyer = order.getBuyer();
            notificationService.createAndPushNotification(
                    null,
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.ORDER,
                    NotificationType.INFORM,
                    "Đơn hàng đã hủy",
                    order.getCancelReasonContent(),
                    order.getPost().getId(),
                    order.getId(),
                    buyer.getId()
            );
        });
    }

    private PageResponse<OrderResponse> convertOrdersToResponse(Page<Order> orders) {
        List<OrderResponse> orderResponses = orders.stream()
                .map(o -> OrderResponse.mapperToOrderResponse(o)).collect(Collectors.toList());
        return new PageResponse<>(
                orderResponses,
                orders.getNumber(),
                orders.getSize(),
                (int) orders.getTotalElements(),
                orders.getTotalPages(),
                orders.isFirst(),
                orders.isLast()
        );
    }

    public PageResponse<OrderResponse> getBuyerPendingOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getBuyerOrders(user.getId(), Order.OrderStatus.PENDING, pageable);
        return convertOrdersToResponse(orders);
    }

    public PageResponse<OrderResponse> getBuyerAcceptedBySellerOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getBuyerOrders(user.getId(), Order.OrderStatus.SELLER_ACCEPTS, pageable);
        return convertOrdersToResponse(orders);
    }

    public PageResponse<OrderResponse> getBuyerAwaitingDepositOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getBuyerOrders(user.getId(), Order.OrderStatus.AWAITING_DEPOSIT, pageable);
        return convertOrdersToResponse(orders);
    }

    public PageResponse<OrderResponse> getBuyerDepositedOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getBuyerOrders(user.getId(), Order.OrderStatus.DEPOSITED, pageable);
        return convertOrdersToResponse(orders);
    }


    public PageResponse<OrderResponse> getBuyerCancelledOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getBuyerOrders(user.getId(), Order.OrderStatus.CANCELLED, pageable);
        return convertOrdersToResponse(orders);
    }

    public PageResponse<OrderResponse> getBuyerCompletedOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getBuyerOrders(user.getId(), Order.OrderStatus.COMPLETED, pageable);
        return convertOrdersToResponse(orders);
    }

    public PageResponse<OrderResponse> getSellerPendingOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getSellerOrders(user.getId(), Order.OrderStatus.PENDING, pageable);
        return convertOrdersToResponse(orders);
    }

    public PageResponse<OrderResponse> getSellerAcceptedOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getSellerOrders(user.getId(), Order.OrderStatus.SELLER_ACCEPTS, pageable);
        return convertOrdersToResponse(orders);
    }

    public PageResponse<OrderResponse> getSellerDepositedOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getSellerOrders(user.getId(), Order.OrderStatus.DEPOSITED, pageable);
        return convertOrdersToResponse(orders);
    }

    public PageResponse<OrderResponse> getSellerCancelledOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getSellerOrders(user.getId(), Order.OrderStatus.CANCELLED, pageable);
        return convertOrdersToResponse(orders);
    }

    public PageResponse<OrderResponse> getSellerCompletedOrders(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.getSellerOrders(user.getId(), Order.OrderStatus.COMPLETED, pageable);
        return convertOrdersToResponse(orders);
    }

    public OrderCounterResponse getOrderCounters(Authentication auth) {
        User user = (User) auth.getPrincipal();
        return OrderCounterResponse.builder()
                .buyerPendingOrderNumber(orderRepository.countBuyerOrdersByStatus(user.getId(), Order.OrderStatus.PENDING))
                .buyerAcceptedOrderNumber(orderRepository.countBuyerOrdersByStatus(user.getId(), Order.OrderStatus.SELLER_ACCEPTS))
                .buyerAwaitingDepositNumber(orderRepository.countBuyerOrdersByStatus(user.getId(), Order.OrderStatus.AWAITING_DEPOSIT))
                .buyerDepositedOrderNumber(orderRepository.countBuyerOrdersByStatus(user.getId(), Order.OrderStatus.DEPOSITED))
                .buyerCancelledOrderNumber(orderRepository.countBuyerOrdersByStatus(user.getId(), Order.OrderStatus.CANCELLED))
                .buyerCompletedOrderNumber(orderRepository.countBuyerOrdersByStatus(user.getId(), Order.OrderStatus.COMPLETED))
                .sellerPendingOrderNumber(orderRepository.countSellerOrdersByStatus(user.getId(), Order.OrderStatus.PENDING))
                .sellerAcceptedOrderNumber(orderRepository.countSellerOrdersByStatus(user.getId(), Order.OrderStatus.SELLER_ACCEPTS))
                .sellerDepositedOrderNumber(orderRepository.countSellerOrdersByStatus(user.getId(), Order.OrderStatus.DEPOSITED))
                .sellerCancelledOrderNumber(orderRepository.countSellerOrdersByStatus(user.getId(), Order.OrderStatus.CANCELLED))
                .sellerCompletedOrderNumber(orderRepository.countSellerOrdersByStatus(user.getId(), Order.OrderStatus.COMPLETED))
                .build();
    }

    public PageResponse<OrderResponse> findOrders(Authentication auth, String keyword, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Order> orders = orderRepository.findOrders(user.getId(), keyword, pageable);
        return convertOrdersToResponse(orders);
    }

    public OrderResponse getOrderById(Authentication auth, String orderId) {
        User user = (User) auth.getPrincipal();
        Order order = orderRepository.findById(orderId).orElseThrow(() -> new RuntimeException("Order not found"));
        if (order.getBuyer().getId() != user.getId() && order.getSeller().getId() != user.getId()) {
            throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
        }
        return OrderResponse.mapperToOrderResponse(order);
    }

    private void sendOrderWebSocket(String username, OrderResponse order) {
        messagingTemplate.convertAndSendToUser(
                username,
                "/queue/order",
                order
        );
    }
}
