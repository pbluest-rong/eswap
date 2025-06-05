import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/app_colors.dart';
import 'package:eswap/main.dart';
import 'package:eswap/model/user_balance.dart';
import 'package:eswap/model/user_model.dart';
import 'package:eswap/presentation/views/account/account_page.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/presentation/widgets/search.dart';
import 'package:eswap/service/balance_service.dart';
import 'package:eswap/service/user_service.dart';
import 'package:flutter/material.dart';

class AdminBalancePage extends StatefulWidget {
  const AdminBalancePage({super.key});

  @override
  State<AdminBalancePage> createState() => _AdminBalancePageState();
}

class _AdminBalancePageState extends State<AdminBalancePage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final BalanceService _balanceService = BalanceService();
  List<UserBalance> _allBalances = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool isRequestWithdrawal = false;

  @override
  void initState() {
    super.initState();
    _loadInitialBalances();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialBalances() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _allBalances = [];
      _currentPage = 0;
      _hasMore = true;
    });

    try {
      final userspage = await _balanceService.fetchBalances(
        isRequestWithdrawal,
        _currentPage,
        _pageSize,
        context,
      );
      setState(() {
        _allBalances = userspage.content;
        _hasMore = !userspage.last;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreUser() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final postpage = await _balanceService.fetchBalances(
          isRequestWithdrawal, _currentPage + 1, _pageSize, context);

      setState(() {
        _currentPage++;
        _allBalances.addAll(postpage.content);
        _hasMore = !postpage.last;
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
        _loadMoreUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isRequestWithdrawal = false;
                  });
                  _loadInitialBalances();
                },
                child: Text(
                  "Tất cả",
                  style: TextStyle(
                    color: !isRequestWithdrawal
                        ? AppColors.lightPrimary
                        : AppColors.lightText,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isRequestWithdrawal = true;
                  });
                  _loadInitialBalances();
                },
                child: Text(
                  "Cần giải ngân",
                  style: TextStyle(
                    color: isRequestWithdrawal
                        ? AppColors.lightPrimary
                        : AppColors.lightText,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
      body: SafeArea(
          child: RefreshIndicator(
              onRefresh: _loadInitialBalances,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                cacheExtent: 1000,
                slivers: [
                  if (_isLoading && _allBalances.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (!_isLoading && _allBalances.isEmpty)
                    SliverFillRemaining(
                      child: Column(
                        children: [
                          const Icon(Icons.currency_exchange,
                              size: 50, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            "no_result_found".tr(),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton(
                            onPressed: _loadInitialBalances,
                            child: Text("retry".tr()),
                          ),
                        ],
                      ),
                    ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < _allBalances.length) {
                        return Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            key: PageStorageKey(
                                'balance_${_allBalances[index].userId}'),
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                    Column(
                                      children: [
                                        _buildBalanceWidget(_allBalances[index]),
                                        Divider()
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      } else if (_hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                    childCount: _allBalances.length + (_hasMore ? 1 : 0),
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,
                  ))
                ],
              ))),
    );
  }

  Widget _buildBalanceWidget(UserBalance balance) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Số dư: ${balance.balance}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Tên ngân hàng: ${balance.bankName ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Chủ tài khoản: ${balance.accountHolder ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Số tài khoản: ${balance.bankAccountNumber ?? ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if (balance.withdrawRequested)
          GestureDetector(
            onTap: () {
              AppAlert.show(
                  context: context,
                  title:
                      "Bạn có chắc chắn đã chuyển tiền về tài khoản người dùng?",
                  actions: [
                    AlertAction(text: "cancel".tr()),
                    AlertAction(
                        isDestructive: true,
                        text: "Xác nhận",
                        handler: () {
                          _balanceService.acceptWithdrawal(
                              balance.userId, context);
                          setState(() {
                            _allBalances.remove(balance);
                          });
                        })
                  ]);
            },
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(Icons.done),
            ),
          )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
