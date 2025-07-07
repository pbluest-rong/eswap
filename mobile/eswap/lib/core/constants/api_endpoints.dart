class ApiEndpoints {
  static String PROTOCOL = "http";
  static String HOST = "192.168.43.108";
  static String PORT = "8080";
  static String CONTEXT_PATH = "/api/v1/";

  static String _baseUrl = PROTOCOL + "://" + HOST + ":" + PORT + CONTEXT_PATH;

  // wss://192.168.1.38:8080/api/v1/ws
  static String ws_url = "ws://" + HOST + ":" + PORT + CONTEXT_PATH + "ws";

  static String login_url = _baseUrl + "auth/login";
  static String refresh_url = _baseUrl + "auth/refresh-token";
  static String requireActivate_url = _baseUrl + "auth/require-activate";
  static String register_email_url = _baseUrl + "auth/register-email";
  static String register_phone_url = _baseUrl + "auth/register-phone";
  static String requireForgotPw_url = _baseUrl + "auth/require-forgotpw";
  static String verifyForgotpw_url = _baseUrl + "auth/verify-forgotpw";
  static String forgotpw_url = _baseUrl + "auth/forgotpw";

  static String getProvinces_url = _baseUrl + "institutions";
  static String checkExist_url = _baseUrl + "auth/check-exist";

  static String saveFcmToken_url = _baseUrl + "notifications/save-fcm-token";
  static String removeFcmToken_url = _baseUrl + "notifications/remove-fcm-token";
  static String getNotifications = _baseUrl + "notifications";
  static String getUnreadNotificationNumber = _baseUrl + "notifications/count-unread";
  static String markAsReadNotification = _baseUrl + "notifications";
  static String getPostsByEducationInstitution_url =
      _baseUrl + "posts/education-institutions";
  static String getPostsOfFollowing = _baseUrl + "posts/following";
  static String getExplorePosts = _baseUrl + "posts";
  static String getPostsByProvince = _baseUrl + "posts/province";
  static String getCategories = _baseUrl + "categories";
  static String getBrandsByCategory = _baseUrl + "categories/brands";
  static String search_url = _baseUrl + "users";
  static String auto_login_url = _baseUrl + "accounts/auto-login";
  static String follow_url = _baseUrl + "accounts/follow";
  static String unfollow_url = _baseUrl + "accounts/unfollow";
  static String accept_follow_url = _baseUrl + "accounts/accept-follow";
  static String remove_follower_url = _baseUrl + "accounts/remove-follow";
  static String like_post_url = _baseUrl + "posts/like";
  static String unlike_post_url = _baseUrl + "posts/unlike";
  static String getPostById_url = _baseUrl + "posts";
  static String detail_accounts_url = _baseUrl + "users";
  static String addPost_url = _baseUrl + "posts";
  static String chats_url = _baseUrl + "chats";
  static String updateAvatar_url = _baseUrl + "accounts/update-avatar";
  static String deleteAvatar_url = _baseUrl + "accounts/delete-avatar";
  static String change_info_url = _baseUrl + "accounts/change-info";
  static String orders_url = _baseUrl + "orders";
  static String orders_buyer_pending_url = _baseUrl + "orders/buyer/pending";
  static String orders_buyer_accepted_url = _baseUrl + "orders/buyer/seller-accepted";
  static String orders_buyer_await_deposit_url = _baseUrl + "orders/buyer/await-deposit";
  static String orders_buyer_deposit_url = _baseUrl + "orders/buyer/deposited";
  static String orders_buyer_cancelled_url = _baseUrl + "orders/buyer/cancelled";
  static String orders_buyer_completed_url = _baseUrl + "orders/buyer/completed";
  static String orders_seller_pending_url = _baseUrl + "orders/seller/pending";
  static String orders_seller_accepted_url = _baseUrl + "orders/seller/accepted";
  static String orders_seller_deposited_url = _baseUrl + "orders/seller/deposited";
  static String orders_seller_cancelled_url = _baseUrl + "orders/seller/cancelled";
  static String orders_seller_completed_url = _baseUrl + "orders/seller/completed";
  static String get_stores_url = _baseUrl + "auth/stores";
  static String admin_url = _baseUrl + "admin";
  static String balances_url = _baseUrl + "balances";
}
