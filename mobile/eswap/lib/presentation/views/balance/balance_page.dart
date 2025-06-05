import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/model/transaction_model.dart';
import 'package:eswap/model/user_balance.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/password_tf.dart';
import 'package:flutter/material.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/service/balance_service.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  final BalanceService _balanceService = BalanceService();
  final ScrollController _scrollController = ScrollController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();

  UserSession? _userSession;
  UserBalance? _balance;
  List<Transaction> _transactions = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userSession = await UserSession.load();
    if (userSession != null) {
      setState(() {
        _userSession = userSession;
      });
      await _fetchBalance();
      await _loadInitialTransactions();
    }
  }

  Future<void> _fetchBalance() async {
    try {
      final balance = await _balanceService.getBalance();
      setState(() {
        _balance = balance;
        _bankNameController.text = balance.bankName ?? '';
        _accountNumberController.text = balance.bankAccountNumber ?? '';
        _accountHolderController.text = balance.accountHolder ?? '';
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadInitialTransactions() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _transactions = [];
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final pageResponse = await _balanceService.fetchTransactions(
        _currentPage,
        _pageSize,
        context,
      );

      setState(() {
        _transactions = pageResponse.content;
        _hasMore = !pageResponse.last;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final pageResponse = await _balanceService.fetchTransactions(
        _currentPage + 1,
        _pageSize,
        context,
      );

      setState(() {
        _currentPage++;
        _transactions.addAll(pageResponse.content);
        _hasMore = !pageResponse.last;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreTransactions();
      }
    });
  }

  Future<void> _requestWithdraw() async {
    try {
      AppAlert.show(
        context: context,
        centerWidget: Column(
          children: [
            TextField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: 'Tên ngân hàng',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Số tài khoản',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _accountHolderController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên chủ tài khoản',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        title: "Thông tin ngân hàng",
        actions: [
          AlertAction(text: "cancel".tr()),
          AlertAction(
            text: "next".tr(),
            isDestructive: true,
            handler: () {
              AppAlert.show(
                  context: context,
                  title: "Vui lòng kiểm tra thông tin trước khi tiếp tục!",
                  description: "Tên ngân hàng: ${_bankNameController.text}\n"
                      "Số tài khoản: ${_accountNumberController.text}\n"
                      "Họ và tên chủ tài khoản: ${_accountHolderController.text}",
                  actions: [
                    AlertAction(text: "cancel".tr()),
                    AlertAction(
                        text: "next".tr(),
                        isDestructive: true,
                        handler: () {
                          TextEditingController pwController =
                              TextEditingController();
                          AppAlert.show(
                              context: context,
                              title: "Nhập mật khẩu Eswap",
                              centerWidget: AppPasswordTextField(
                                  labelText: "pw".tr(),
                                  validatePassword: false,
                                  controller: pwController),
                              actions: [
                                AlertAction(text: "cancel".tr()),
                                AlertAction(
                                    text: "confirm".tr(),
                                    isDestructive: true,
                                    handler: () async {
                                      final balance =
                                          await _balanceService.requestWithdraw(
                                        bankName: _bankNameController.text,
                                        accountNumber:
                                            _accountNumberController.text,
                                        accountHolder:
                                            _accountHolderController.text,
                                        password: pwController.text,
                                        context: context,
                                      );
                                      setState(() {
                                        _balance = balance;
                                      });
                                    })
                              ]);
                        })
                  ]);
            },
          ),
        ],
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to request withdrawal: ${e.toString()}')),
      );
    }
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isDeposit = transaction.type == TransactionType.DEPOSIT ||
        transaction.type == TransactionType.DEPOSIT_RELEASE_TO_SELLER;
    final icon = isDeposit
        ? Icons.account_balance_wallet_outlined
        : Icons.currency_exchange;

    final amountColor = (transaction.type == TransactionType.DEPOSIT)
        ? Colors.black
        : (transaction.type == TransactionType.WITHDRAWAL)
            ? Colors.red
            : Colors.green;
    final amountPrefix = (transaction.type == TransactionType.DEPOSIT)
        ? ''
        : (transaction.type == TransactionType.WITHDRAWAL)
            ? '-'
            : '+';

    return ListTile(
      leading: Icon(icon),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(typeAsName(transaction.type)),
          Text('#${transaction.id}'),
        ],
      ),
      subtitle:
          Text(DateFormat('dd/MM/yyyy, hh:mm a').format(transaction.createdAt)),
      trailing: Text(
        '$amountPrefix${transaction.amount.toStringAsFixed(0)} VND',
        style: TextStyle(
            color: amountColor, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  String typeAsName(TransactionType type) {
    switch (type) {
      case TransactionType.DEPOSIT:
        return "Đặt cọc";
      case TransactionType.DEPOSIT_REFUND:
        return "Hoàn tiền đặt cọc";
      case TransactionType.DEPOSIT_RELEASE_TO_SELLER:
        return "Nhận tiền đặt cọc";
      case TransactionType.WITHDRAWAL:
        return "Rút tiền";
      default:
        return "Giao dịch";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title: const Text('Giao dịch đặt cọc'),
        backgroundColor: AppColors.lightPrimary,
      ),
      body: _isLoading && _balance == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialTransactions,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Balance Card
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'Số dư',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_balance?.balance?.toStringAsFixed(0) ?? '0'} VND',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: _requestWithdraw,
                                      child: const Text(
                                        'Gửi yêu cầu rút tiền',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Transaction History
                          const Text(
                            'Giao dịch gần đây',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  if (_transactions.isEmpty && !_isLoading)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long,
                                size: 50, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              "no_transactions_found".tr(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: _loadInitialTransactions,
                              child: Text("retry".tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < _transactions.length) {
                          return Column(
                            children: [
                              _buildTransactionItem(_transactions[index]),
                              const Divider(height: 1),
                            ],
                          );
                        } else if (_hasMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return null;
                      },
                      childCount: _transactions.length + (_hasMore ? 1 : 0),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
