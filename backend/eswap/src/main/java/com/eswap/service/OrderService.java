package com.eswap.service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.constants.PageResponse;
import com.eswap.common.exception.AlreadyExistsException;
import com.eswap.common.exception.OperationNotPermittedException;
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
import com.eswap.service.payment.CreatePaymentResponse;
import com.eswap.service.payment.PaymentService;
import com.eswap.service.payment.PaymentServiceFactory;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
    private final UserRepository userRepository;
    private final TransactionRepository transactionRepository;
    private final PostRepository postRepository;
    private final PaymentServiceFactory paymentServiceFactory;
    private final PaymentService paymentService;
    private final SimpMessagingTemplate messagingTemplate;

    // User đại diện cho hệ thống (escrow)
    private static final Long SYSTEM_ESCROW_USER_ID = 1L;

    /**
     * Người mua tạo order với status là AWAITING_DEPOSIT (chờ đặt cọc để thành DEPOSITED - giữ chỗ hoặc chờ người bán xác nhận rằng sẽ bán cho người này)
     * hoặc là PENDING (chờ người bán xác nhận)
     *
     * @param postId
     * @param quantity
     * @return
     */
    public OrderCreationResponse createOrder(Authentication connectedUser, long postId, int quantity, String paymentType) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        User buyer = (User) connectedUser.getPrincipal();

        Order checkOrder = orderRepository.findByPostAndBuyerUnprocessed(postId, buyer.getId());

        if (checkOrder != null && (checkOrder.getStatus() == Order.OrderStatus.PENDING || checkOrder.getStatus() == Order.OrderStatus.AWAITING_DEPOSIT))
            throw new AlreadyExistsException(AppErrorCode.ORDER_EXISTS);

        // Validate số lượng
        if (quantity <= 0 || quantity > post.getQuantity() - post.getSold()) {
            throw new IllegalArgumentException("Invalid quantity");
        }
        // Tính toán giá trị
        BigDecimal totalAmount = post.getSalePrice().multiply(BigDecimal.valueOf(quantity));

        String orderId = "ORDER-" + UUID.randomUUID();
        //deposit
        if (paymentType != null && !paymentType.isEmpty()) {
            PaymentService service = paymentServiceFactory.getService(paymentType);
            if (service == null) {
                log.error("Loại thanh toán không hỗ trợ: {}", paymentType);
                return null;
            }
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
                    .status(Order.OrderStatus.AWAITING_DEPOSIT)
                    .build();
            order = orderRepository.save(order);
            //QR thanh toán
            CreatePaymentResponse paymentResponse = paymentService.createPaymentQR(order, "");
            OrderResponse orderResponse = OrderResponse.mapperToOrderResponse(order);
            return new OrderCreationResponse(orderResponse, paymentResponse);
        } else {
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
            return new OrderCreationResponse(orderResponse, null);
        }
    }

    // < 300.000 -> 20.000
    // 300 - 1tr -> 50.000
    // > 1tr -> 10%
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
     * Xử lý khi nhận thanh toán thành công từ Momo,...
     *
     * @param orderId
     * @param paymentTransactionId
     */
    public void handleDepositSuccess(String orderId, String paymentTransactionId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        if (order.getStatus() != Order.OrderStatus.AWAITING_DEPOSIT) {
            throw new IllegalStateException("Only PENDING orders can be deposited");
        }

        // Cập nhật số lượng đã bán
        Post post = order.getPost();
        post.setSold(post.getSold() + order.getQuantity());
        postRepository.save(post);
        // Tạo transaction deposit
        User escrowUser = userRepository.findById(SYSTEM_ESCROW_USER_ID)
                .orElseThrow(() -> new RuntimeException("System escrow user not configured"));
        Transaction transaction = Transaction.builder()
                .order(order)
                .type(Transaction.TransactionType.DEPOSIT)
                .amount(order.getDepositAmount())
                .momoTransactionId(paymentTransactionId)
                .status(Transaction.TransactionStatus.SUCCESS)
                .sender(order.getBuyer())
                .receiver(escrowUser)
                .build();

        transactionRepository.save(transaction);

        // Cập nhật trạng thái order
        order.setStatus(Order.OrderStatus.DEPOSITED);
        orderRepository.save(order);

        messagingTemplate.convertAndSendToUser(
                order.getBuyer().getUsername(),
                "/queue/deposit-order",
                OrderResponse.mapperToOrderResponse(order)
        );
    }

    public CreatePaymentResponse deposit(Authentication connectedUser, String orderId) {
        User seller = (User) connectedUser.getPrincipal();
        Order order = orderRepository.findByIdAndSeller(orderId, seller.getId());

        if (order == null) throw new ResourceNotFoundException(AppErrorCode.ORDER_NOT_FOUND, "id", orderId);
        if (order.getStatus() != Order.OrderStatus.AWAITING_DEPOSIT) {
            throw new IllegalStateException("Only AWAITING_DEPOSIT orders can be deposit");
        }
        //QR thanh toán
        CreatePaymentResponse paymentResponse = paymentService.createPaymentQR(order, "");
        OrderResponse orderResponse = OrderResponse.mapperToOrderResponse(order);
        return paymentResponse;
    }

    public OrderResponse deleteOrder(Authentication connectedUser, String orderId) {
        User user = (User) connectedUser.getPrincipal();
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.ORDER_NOT_FOUND, "id", orderId));
        Boolean isBuyer;
        if (user.getId() == order.getBuyer().getId()) isBuyer = true;
        else if (user.getId() == order.getSeller().getId()) isBuyer = false;
        else return null;

        // Chỉ cho phép xóa khi awaiting deposit,
        if (order.getStatus() != Order.OrderStatus.AWAITING_DEPOSIT) {
            throw new IllegalStateException("Only AWAITING_DEPOSIT orders can be deposited");
        }

        order.setStatus(Order.OrderStatus.DELETED);
        OrderResponse response = OrderResponse.mapperToOrderResponse(order);
        return response;
    }

    public OrderResponse handleSellerAcceptNoDeposit(Authentication connectedUser, String orderId) {
        User seller = (User) connectedUser.getPrincipal();
        Order order = orderRepository.findByIdAndSeller(orderId, seller.getId());

        if (order == null) throw new ResourceNotFoundException(AppErrorCode.ORDER_NOT_FOUND, "id", orderId);
        if (order.getStatus() != Order.OrderStatus.PENDING) {
            throw new IllegalStateException("Only PENDING orders can be deposited");
        }

        // Cập nhật số lượng đã bán
        Post post = order.getPost();
        post.setSold(post.getSold() + order.getQuantity());
        postRepository.save(post);

        // Cập nhật trạng thái order
        order.setDepositAmount(BigDecimal.ZERO);
        order.setRemainingAmount(order.getTotalAmount());
        order.setStatus(Order.OrderStatus.SELLER_ACCEPTS);
        order = orderRepository.save(order);
        OrderResponse response = OrderResponse.mapperToOrderResponse(order);
        return response;
    }

    /**
     * Người mua có thể hủy order nếu status != COMPLETED
     *
     * @param orderId
     */
    @Transactional
    public OrderResponse cancelOrder(Authentication connected, String orderId, String cancelReasonContent) {
        User user = (User) connected.getPrincipal();
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.ORDER_NOT_FOUND, "id", orderId));
        Boolean isBuyer;
        if (user.getId() == order.getBuyer().getId()) isBuyer = true;
        else if (user.getId() == order.getSeller().getId()) isBuyer = false;
        else return null;

        // Chỉ cho phép hủy khi chưa hoàn tất,
        if (order.getStatus() == Order.OrderStatus.COMPLETED && order.getStatus() == Order.OrderStatus.DELETED) {
            throw new IllegalStateException("Completed orders cannot be cancelled");
        }
        // Chỉ cho phép người mua mới hủy đơn đang đợi đặt cọc
        if (!isBuyer && order.getStatus() == Order.OrderStatus.AWAITING_DEPOSIT) {
            throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
        }
        // cập nhật status order -> CANCELLED
        order.setStatus(Order.OrderStatus.CANCELLED);
        order.setCancelReason(isBuyer ? Order.CancelReason.BUYER_CANCELLED : Order.CancelReason.SELLER_REJECTED);
        order.setCancelReasonContent(cancelReasonContent);
        order = orderRepository.save(order);
        // Nếu đã trừ sold (DEPOSITED) thì cộng lại
        if (order.getStatus() == Order.OrderStatus.DEPOSITED) {
            Post post = order.getPost();
            post.setSold(post.getSold() - order.getQuantity());
            postRepository.save(post);
        }
        // Xử lý hoàn tiền NẾU đã đặt cọc
        if (order.getStatus() == Order.OrderStatus.DEPOSITED) {
            User escrowUser = userRepository.findById(SYSTEM_ESCROW_USER_ID)
                    .orElseThrow(() -> new RuntimeException("System escrow user not configured"));

            // Tạo transaction hoàn tiền
            Transaction refundTransaction = Transaction.builder()
                    .order(order)
                    .type(Transaction.TransactionType.REFUND)
                    .amount(order.getDepositAmount())
                    .status(Transaction.TransactionStatus.SUCCESS)
                    .sender(escrowUser)
                    .receiver(order.getBuyer())
                    .build();

            transactionRepository.save(refundTransaction);
            // refund payment
            paymentService.refundPayment(
                    findOriginalDepositTransaction(orderId).getMomoTransactionId(),
                    order.getDepositAmount()
            );
        }
        OrderResponse response = OrderResponse.mapperToOrderResponse(order);
        return response;
    }

    @Transactional
    public OrderResponse completeOrder(Authentication connected, String orderId) {
        User user = (User) connected.getPrincipal();
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        Boolean isBuyer;
        if (user.getId() == order.getBuyer().getId()) isBuyer = true;
        else if (user.getId() == order.getSeller().getId()) isBuyer = false;
        else return null;

        // Chỉ cho phép hoàn thành khi ở trạng thái đặt cọc hoặc người bán cho phép
        if (!(order.getStatus() == Order.OrderStatus.DEPOSITED || order.getStatus() == Order.OrderStatus.SELLER_ACCEPTS)) {
            throw new IllegalStateException("Completed orders cannot be cancelled");
        }
        // Chỉ cho phép người mua mới hủy đơn đang đợi đặt cọc
        if (!isBuyer && order.getStatus() == Order.OrderStatus.AWAITING_DEPOSIT) {
            throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
        }

        // buyer handle
        if (isBuyer) {
            // Chỉ cho phép người mua hoàn thành khi đã đặt cọc
            if (order.getStatus() != Order.OrderStatus.DEPOSITED) {
                throw new IllegalStateException("Only DEPOSITED orders can be completed");
            }

            // Cập nhật trạng thái đơn
            order.setStatus(Order.OrderStatus.COMPLETED);
            order = orderRepository.save(order);

            // Transaction giải ngân tiền cọc cho người bán
            User escrowUser = userRepository.findById(SYSTEM_ESCROW_USER_ID)
                    .orElseThrow(() -> new RuntimeException("System escrow user not configured"));
            Transaction depositRelease = Transaction.builder()
                    .order(order)
                    .type(Transaction.TransactionType.DEPOSIT_RELEASE)
                    .amount(order.getDepositAmount())
                    .status(Transaction.TransactionStatus.SUCCESS)
                    .sender(escrowUser)
                    .receiver(order.getSeller())
                    .build();
            transactionRepository.save(depositRelease);
            // Tạm thời: Gửi thông báo về người bán -> điền số tài khoản -> admin chuyển khoản
            paymentService.refundPayment(
                    findOriginalDepositTransaction(orderId).getMomoTransactionId(),
                    order.getDepositAmount()
            );
        }
        // seller handle
        else {
            // Chỉ cho phép người bán hoàn thàng khi order là SELLER_ACCEPTS
            if (order.getStatus() != Order.OrderStatus.SELLER_ACCEPTS) {
                throw new IllegalStateException("Only SELLER_ACCEPTS orders can be completed");
            }
            // Cập nhật trạng thái đơn
            order.setStatus(Order.OrderStatus.COMPLETED);
            order = orderRepository.save(order);
        }
        OrderResponse response = OrderResponse.mapperToOrderResponse(order);
        return response;
    }

    private Transaction findOriginalDepositTransaction(String orderId) {
        return transactionRepository.findByOrderIdAndType(orderId, Transaction.TransactionType.DEPOSIT)
                .orElseThrow(() -> new RuntimeException("Original deposit transaction not found"));
    }


    // Hủy order PEDING
    @Scheduled(fixedRate = 3600000)
    @Transactional
    @Async // Xử lý bất đồng bộ
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
            // 5. Ghi log
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
}
