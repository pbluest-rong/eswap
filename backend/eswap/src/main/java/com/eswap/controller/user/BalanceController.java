package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.PageResponse;
import com.eswap.response.MessageResponse;
import com.eswap.response.TransactionResponse;
import com.eswap.response.UserBalanceResponse;
import com.eswap.service.BalanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("balances")
@RequiredArgsConstructor
public class BalanceController {
    private final BalanceService balanceService;

    @GetMapping()
    public ResponseEntity<ApiResponse> getBalanceByUserId(Authentication auth) {
        UserBalanceResponse balanceResponse = balanceService.getBalance(auth);
        return ResponseEntity.ok(new ApiResponse(true, "success", balanceResponse));
    }

    @PostMapping("/withdraw")
    public ResponseEntity<ApiResponse> requestWithdraw(Authentication auth,
                                                       @RequestParam String bankName,
                                                       @RequestParam String accountNumber,
                                                       @RequestParam String holder,
                                                       @RequestParam String password) {
        UserBalanceResponse balanceResponse = balanceService.requestWithdraw(auth, bankName, accountNumber, holder, password);

        return ResponseEntity.ok(new ApiResponse(true, "success", balanceResponse));
    }

    @GetMapping("/transactions")
    public ResponseEntity<ApiResponse> getMessages(Authentication auth, @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "15") int size) {
        PageResponse<TransactionResponse> data = balanceService.getTransaction(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "transactions", data));
    }
}