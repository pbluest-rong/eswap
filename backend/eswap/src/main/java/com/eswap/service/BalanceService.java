package com.eswap.service;

import com.eswap.common.exception.AlreadyExistsException;
import com.eswap.common.exception.InvalidCredentialsException;
import com.eswap.response.TransactionResponse;
import com.eswap.response.UserBalanceResponse;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.constants.PageResponse;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.kafka.chat.ChatProducer;
import com.eswap.model.*;
import com.eswap.repository.*;
import com.eswap.request.MessageRequest;
import com.eswap.response.ChatResponse;
import com.eswap.response.MessageResponse;
import com.eswap.service.upload.UploadService;
import com.google.gson.Gson;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BalanceService {
    private final UserBalanceRepository balanceRepository;
    private final TransactionRepository transactionRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    private final AuthenticationManager authenticationManager;

    /**
     * Lấy số dư tài khoản.
     */
    public UserBalanceResponse getBalance(Authentication auth) {
        User user = (User) auth.getPrincipal();
        UserBalance balance = balanceRepository.findById(user.getId()).orElse(
                null
        );
        if (balance == null) {
            balance = new UserBalance();
            balance.setUserId(user.getId());
        }
        return UserBalanceResponse.mapperToOrderResponse(balance);
    }


    public void depositTransactionOfBuyer(Order order, String paymentTransactionId) {
        Transaction transaction = Transaction.builder()
                .order(order)
                .type(Transaction.TransactionType.DEPOSIT)
                .amount(order.getDepositAmount())
                .momoTransactionId(paymentTransactionId)
                .status(Transaction.TransactionStatus.SUCCESS)
                .sender(order.getBuyer())
                .receiver(order.getBuyer())
                .createdAt(OffsetDateTime.now())
                .build();
        transactionRepository.save(transaction);
    }

    public void depositRefundToBuyer(Order order) {
        User buyer = order.getBuyer();
        UserBalance balance = balanceRepository.findById(buyer.getId()).orElse(new UserBalance());
        balance.setUserId(buyer.getId());
        balance.setBalance(balance.getBalance().add(order.getDepositAmount()));
        balanceRepository.save(balance);
        Transaction transaction = Transaction.builder()
                .order(order)
                .type(Transaction.TransactionType.DEPOSIT_REFUND)
                .amount(order.getDepositAmount())
                .status(Transaction.TransactionStatus.SUCCESS)
                .receiver(buyer)
                .createdAt(OffsetDateTime.now())
                .build();
        transactionRepository.save(transaction);
    }

    public void depositReleaseToSeller(Order order) {
        User seller = order.getSeller();
        UserBalance balance = balanceRepository.findById(seller.getId()).orElse(new UserBalance());
        balance.setUserId(seller.getId());
        balance.setBalance(balance.getBalance().add(order.getDepositAmount()));
        balanceRepository.save(balance);
        Transaction transaction = Transaction.builder()
                .order(order)
                .type(Transaction.TransactionType.DEPOSIT_RELEASE_TO_SELLER)
                .amount(order.getDepositAmount())
                .status(Transaction.TransactionStatus.SUCCESS)
                .sender(order.getBuyer())
                .receiver(seller)
                .createdAt(OffsetDateTime.now())
                .build();
        transactionRepository.save(transaction);
    }

    /**
     * Rút tiền
     */
    public UserBalanceResponse requestWithdraw(Authentication auth, String bankName, String accountNumber, String holder, String password) {
        User user = (User) auth.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        System.out.println(password);
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            user.getUsername(),
                            password
                    )
            );
        } catch (Exception e) {
            throw new InvalidCredentialsException(AppErrorCode.USER_PW_INVALID_CREDENTIALS);
        }

        UserBalance balance = balanceRepository.findById(user.getId()).orElse(null);
        if (balance == null) {
            balance = new UserBalance();
            balance.setUserId(user.getId());
            balance.setBankName(bankName);
            balance.setBankAccountNumber(accountNumber);
            balance.setAccountHolder(holder);
            balance.setWithdrawRequested(true);
            balance.setWithdrawDateTime(OffsetDateTime.now());
            balance = balanceRepository.save(balance);
        } else {
            if (balance.getBalance().compareTo(new BigDecimal("50000")) < 0) {
                throw new AlreadyExistsException(AppErrorCode.WITHDRAWAL_REQUEST_LIMIT_EXCEEDED);
            }
            // Đang đợi xử lý
            if (balance.isWithdrawRequested())
                throw new AlreadyExistsException(AppErrorCode.WITHDRAWAL_REQUEST_LIMIT_EXCEEDED);
            else {
                balance.setBankName(bankName);
                balance.setBankAccountNumber(accountNumber);
                balance.setAccountHolder(holder);
                balance.setWithdrawRequested(true);
                balance.setWithdrawDateTime(OffsetDateTime.now());
                balance = balanceRepository.save(balance);
            }
        }
        return UserBalanceResponse.mapperToOrderResponse(balance);
    }

    public UserBalanceResponse adminAcceptWithdrawal(long userId) {
        User user = userRepository.findById(userId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", userId));
        UserBalance balance = balanceRepository.findByUserId(userId).orElse(null);
        if (balance != null) {
            Transaction transaction = Transaction.builder()
                    .type(Transaction.TransactionType.WITHDRAWAL)
                    .amount(balance.getBalance())
                    .status(Transaction.TransactionStatus.SUCCESS)
                    .receiver(user)
                    .createdAt(OffsetDateTime.now())
                    .build();
            transactionRepository.save(transaction);
            balance.setBalance(BigDecimal.ZERO);
            balance.setWithdrawDateTime(null);
            balance.setWithdrawRequested(false);
            balance = balanceRepository.save(balance);
            return UserBalanceResponse.mapperToOrderResponse(balance);
        }
        throw new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND);
    }

    /**
     * Get transaction
     */
    public PageResponse<TransactionResponse> getTransaction(Authentication auth, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size);
        Page<Transaction> transactions = transactionRepository
                .getTransactions(user.getId(), pageable);
        List<TransactionResponse> transactionResponses = transactions.stream().map(
                t -> TransactionResponse.mapperToOrderResponse(t)
        ).collect(Collectors.toList());
        return new PageResponse<>(
                transactionResponses,
                transactions.getNumber(),
                transactions.getSize(),
                (int) transactions.getTotalElements(),
                transactions.getTotalPages(),
                transactions.isFirst(),
                transactions.isLast()
        );
    }


    public PageResponse<UserBalanceResponse> getBalances(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<UserBalance> balances = balanceRepository
                .getBalances(pageable);
        List<UserBalanceResponse> balanceResponses = balances.stream().map(
                b -> UserBalanceResponse.mapperToOrderResponse(b)
        ).collect(Collectors.toList());
        return new PageResponse<>(
                balanceResponses,
                balances.getNumber(),
                balances.getSize(),
                (int) balances.getTotalElements(),
                balances.getTotalPages(),
                balances.isFirst(),
                balances.isLast()
        );
    }

    public PageResponse<UserBalanceResponse> getRequestWithdrawalBalances(int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<UserBalance> balances = balanceRepository
                .getRequestWithdrawalBalances(pageable);
        List<UserBalanceResponse> balanceResponses = balances.stream().map(
                b -> UserBalanceResponse.mapperToOrderResponse(b)
        ).collect(Collectors.toList());
        return new PageResponse<>(
                balanceResponses,
                balances.getNumber(),
                balances.getSize(),
                (int) balances.getTotalElements(),
                balances.getTotalPages(),
                balances.isFirst(),
                balances.isLast()
        );
    }
}
