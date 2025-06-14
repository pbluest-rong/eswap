class Dashboard {
  final int totalUsers;
  final int totalPosts;
  final int totalOrders;
  final int totalTransactions;

  Dashboard(
      {required this.totalUsers,
      required this.totalPosts,
      required this.totalOrders,
      required this.totalTransactions});

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
        totalUsers: json['totalUsers'],
        totalPosts: json['totalPosts'],
        totalOrders: json['totalOrders'],
        totalTransactions: json['totalTransactions']);
  }
}
