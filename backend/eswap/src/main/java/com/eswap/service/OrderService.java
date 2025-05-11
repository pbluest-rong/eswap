package com.eswap.service;

import com.eswap.model.Order;
import com.eswap.model.Post;
import com.eswap.model.Transaction;
import com.eswap.model.User;
import com.eswap.repository.OrderRepository;
import com.eswap.repository.PostRepository;
import com.eswap.repository.TransactionRepository;
import com.eswap.repository.UserRepository;
import com.eswap.service.payment.CreatePaymentResponse;
import com.eswap.service.payment.PaymentService;
import com.eswap.service.payment.PaymentServiceFactory;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

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

    // User đại diện cho hệ thống (escrow)
    private static final Long SYSTEM_ESCROW_USER_ID = 1L;

    /**
     * Người mua tạo order với status là PENDING (chờ đặt cọc để thành DEPOSITED - giữ chỗ hoặc chờ người bán xác nhận rằng sẽ bán cho người này)
     *
     * @param postId
     * @param quantity
     * @return
     */
    public Order createOrder(Authentication connectedUser, long postId, int quantity) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        User buyer = (User) connectedUser.getPrincipal();

        // Validate số lượng
        if (quantity <= 0 || quantity > post.getQuantity() - post.getSold()) {
            throw new IllegalArgumentException("Invalid quantity");
        }
        // Tính toán giá trị
        BigDecimal totalAmount = post.getSalePrice().multiply(BigDecimal.valueOf(quantity));
        BigDecimal depositAmount = calDepositAmount(totalAmount);

        String orderId = "ORDER-" + UUID.randomUUID();
        Order order = Order.builder()
                .id(orderId)
                .post(post)
                .buyer(buyer)
                .seller(post.getUser())
                .quantity(quantity)
                .totalAmount(totalAmount)
                .depositAmount(depositAmount)
                .remainingAmount(totalAmount.subtract(depositAmount))
                .status(Order.OrderStatus.PENDING)
                .build();

        return orderRepository.save(order);
    }

    // < 300.000 -> 20.000
    // 300 - 1tr -> 50.000
    // > 1tr -> 10%
    private BigDecimal calDepositAmount(BigDecimal amount) {
        if (amount.compareTo(new BigDecimal("300000")) < 0) {
            return new BigDecimal("20000");
        } else if (amount.compareTo(new BigDecimal("1000000")) <= 0) {
            return new BigDecimal("50000");
        } else {
            return amount.multiply(new BigDecimal("0.10")).setScale(0, RoundingMode.DOWN);
        }
    }

    /**
     * Người mua đặt cọc để order là DEPOSITED nhằm giữ chỗ
     *
     * @param orderId
     * @return
     */
    public CreatePaymentResponse processDeposit(Authentication connectedUser, String orderId, String paymentType) {
        User buyer = (User) connectedUser.getPrincipal();

        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        if (order.getBuyer().getId() != buyer.getId())
            throw new IllegalArgumentException("Invalid buyer");
        if (order.getStatus() != Order.OrderStatus.PENDING) {
            throw new IllegalStateException("Order is not in PENDING state");
        }
        PaymentService service = paymentServiceFactory.getService(paymentType);
        if (service == null) {
            log.error("Loại thanh toán không hỗ trợ: {}", paymentType);
            return null;
        }
        //QR thanh toán
        return paymentService.createPaymentQR(order, "");
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

        if (order.getStatus() != Order.OrderStatus.PENDING) {
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
    }

    public void handleSellerAcceptNoDeposit(Authentication connectedUser, String orderId) {
        User seller = (User) connectedUser.getPrincipal();
        Order order = orderRepository.findByIdAndSeller(orderId, seller.getId());

        if (order == null) return;
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
        orderRepository.save(order);
    }

    /**
     * Người mua có thể hủy order nếu status != COMPLETED
     *
     * @param orderId
     */
    @Transactional
    public void cancelOrder(Authentication connected, String orderId, String cancelReasonContent) {
        User user = (User) connected.getPrincipal();
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        Boolean isBuyer;
        if (user.getId() == order.getBuyer().getId()) isBuyer = true;
        else if (user.getId() == order.getSeller().getId()) isBuyer = false;
        else isBuyer = null;
        if (isBuyer == null) return;

        // Chỉ cho phép hủy khi chưa hoàn tất
        if (order.getStatus() == Order.OrderStatus.COMPLETED) {
            throw new IllegalStateException("Completed orders cannot be cancelled");
        }
        // cập nhật status order -> CANCELLED
        order.setStatus(Order.OrderStatus.CANCELLED);
        order.setCancelReason(isBuyer ? Order.CancelReason.BUYER_CANCELLED : Order.CancelReason.SELLER_REJECTED);
        order.setCancelReasonContent(cancelReasonContent);
        orderRepository.save(order);
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
    }

    @Transactional
    public void completeOrder(Authentication connected, String orderId) {
        User user = (User) connected.getPrincipal();
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        Boolean isBuyer;
        if (user.getId() == order.getBuyer().getId()) isBuyer = true;
        else if (user.getId() == order.getSeller().getId()) isBuyer = false;
        else isBuyer = null;
        if (isBuyer == null) return;
        // buyer handle
        if (isBuyer) {
            // Chỉ cho phép người mua hoàn thàng khi đã đặt cọc
            if (order.getStatus() != Order.OrderStatus.DEPOSITED) {
                throw new IllegalStateException("Only DEPOSITED orders can be completed");
            }

            // Cập nhật trạng thái đơn
            order.setStatus(Order.OrderStatus.COMPLETED);
            orderRepository.save(order);

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
            orderRepository.save(order);
        }
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
}
