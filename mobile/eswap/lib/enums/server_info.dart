class ServerInfo {
  static const String PROTOCOL = "http";
  static const String HOST = "192.168.1.33";
  static const String PORT = "8080";
  static const String CONTEXT_PATH = "/api/v1/";

  static const String _headUrl =
      PROTOCOL + "://" + HOST + ":" + PORT + CONTEXT_PATH;

  static const String login_url = _headUrl + "auth/login";
  static const String requireActivateEmail_url = _headUrl + "auth/require-activate-email";
  static const String register_url = _headUrl + "auth/register";
  static const String requireForgotPw_url = _headUrl + "auth/require-forgotpw";
  static const String verifyForgotpw_url= _headUrl + "auth/verify-forgotpw";
  static const String forgotpw_url= _headUrl + "auth/forgotpw";

  static const String getProvinces_url= _headUrl + "institutions";
  static const String checkExistEmail_url= _headUrl + "auth/check-exist-email";
}
