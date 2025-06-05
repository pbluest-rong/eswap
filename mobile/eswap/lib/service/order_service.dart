import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/model/order.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/auth_interceptor.dart';
import 'package:flutter/cupertino.dart';

class OrderService {
  final dio = Dio();

  OrderService() {
    dio.interceptors.add(AuthInterceptor(dio));
  }

  Future<OrderCreation> createOrderByBuyer(
      {required int postId,
      required int quantity,
      String? paymentType,
      required BuildContext context}) async {
    try {
      final userSession = await UserSession.load();
      final response = await dio.post(ApiEndpoints.orders_url,
          queryParameters: {
            'postId': postId,
            'quantity': quantity,
            'paymentType': paymentType
          },
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": Localizations.localeOf(context).languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final orderCreation = OrderCreation.fromJson(responseData);
        return orderCreation;
      } else {
        throw Exception("Failed to create order");
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          showNotificationDialog(
              context, "Bạn đã tạo đơn hàng trước đó");
        } else {
          showNotificationDialog(context, "network_error".tr());
        }
      }else{
        showNotificationDialog(context, "general_error".tr());
      }
      throw Exception("Failed to create order: ${e.toString()}");
    }
  }

  Future<double> calDepositAmount(double amount) async {
    try {
      final userSession = await UserSession.load();
      final response =
          await dio.get("${ApiEndpoints.orders_url}/cal-deposit-amount/$amount",
              options: Options(headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${userSession!.accessToken}",
              }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        return responseData.toDouble();
      } else {
        throw Exception(response.data["message"] ?? "Failed to create order");
      }
    } catch (e) {
      throw Exception("Failed to create order: ${e.toString()}");
    }
  }

  Future<OrderCreation> depositByBuyer(
      String orderId, String paymentType, BuildContext context) async {
    try {
      final userSession = await UserSession.load();
      final response = await dio.put("${ApiEndpoints.orders_url}/deposit",
          queryParameters: {'orderId': orderId, 'paymentType': paymentType},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": Localizations.localeOf(context).languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final responseObject = OrderCreation.fromJson(responseData);
        return responseObject;
      } else {
        AppAlert.show(
            context: context,
            title: response.data['data']["message"] ?? "general_error".tr(),
            actions: [AlertAction(text: "OK")]);
        throw Exception(response.data["message"] ?? "Failed to deposit order");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Order> acceptNoDepositBySeller(
      String orderId, BuildContext context) async {
    try {
      final userSession = await UserSession.load();
      final response =
          await dio.put("${ApiEndpoints.orders_url}/accept-no-deposit",
              queryParameters: {'orderId': orderId},
              options: Options(headers: {
                "Content-Type": "application/json",
                "Accept-Language": Localizations.localeOf(context).languageCode,
                "Authorization": "Bearer ${userSession!.accessToken}",
              }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final order = Order.fromJson(responseData);
        return order;
      } else {
        throw Exception(response.data["message"] ??
            "Failed to accept no deposit for order");
      }
    } catch (e) {
      throw Exception(
          "Failed to  accept no deposit for order: ${e.toString()}");
    }
  }

  Future<Order> cancelOrder(
      String orderId, String cancelReasonContent, BuildContext context) async {
    try {
      final userSession = await UserSession.load();
      final response = await dio.put("${ApiEndpoints.orders_url}/cancel",
          queryParameters: {
            'orderId': orderId,
            'cancelReasonContent': cancelReasonContent
          },
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": Localizations.localeOf(context).languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final order = Order.fromJson(responseData);
        return order;
      } else {
        throw Exception(response.data["message"] ?? "Failed to cancel order");
      }
    } catch (e) {
      throw Exception("Failed to cancel order: ${e.toString()}");
    }
  }

  Future<Order> completeOrder(String orderId, BuildContext context) async {
    try {
      final userSession = await UserSession.load();
      final response = await dio.put("${ApiEndpoints.orders_url}/complete",
          queryParameters: {
            'orderId': orderId,
          },
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": Localizations.localeOf(context).languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final order = Order.fromJson(responseData);
        return order;
      } else {
        throw Exception(response.data["message"] ?? "Failed to complete order");
      }
    } catch (e) {
      throw Exception("Failed to complete order: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> getOrderCounters() async {
    try {
      final userSession = await UserSession.load();
      final response = await dio.get("${ApiEndpoints.orders_url}/counter",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        return responseData;
      } else {
        throw Exception(
            response.data["message"] ?? "Failed to load order counter");
      }
    } catch (e) {
      throw Exception("Failed to load order counter: ${e.toString()}");
    }
  }

  Future<PageResponse<Order>> fetchOrders(bool isSellOrders, int status,
      int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();
      String url = "";
      if (isSellOrders) {
        if (status == 0) {
          url = ApiEndpoints.orders_seller_pending_url;
        } else if (status == 1) {
          url = ApiEndpoints.orders_seller_accepted_url;
        } else if (status == 2) {
          url = ApiEndpoints.orders_seller_deposited_url;
        } else if (status == 3) {
          url = ApiEndpoints.orders_seller_cancelled_url;
        } else if (status == 4) {
          url = ApiEndpoints.orders_seller_completed_url;
        }
      } else {
        if (status == 0) {
          url = ApiEndpoints.orders_buyer_pending_url;
        } else if (status == 1) {
          url = ApiEndpoints.orders_buyer_accepted_url;
        } else if (status == 2) {
          url = ApiEndpoints.orders_buyer_await_deposit_url;
        } else if (status == 3) {
          url = ApiEndpoints.orders_buyer_deposit_url;
        } else if (status == 4) {
          url = ApiEndpoints.orders_buyer_cancelled_url;
        } else if (status == 5) {
          url = ApiEndpoints.orders_buyer_completed_url;
        }
      }
      final response = await dio.get(url,
          queryParameters: {'page': page, 'size': size},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Order>.fromJson(
          responseData,
          (json) => Order.fromJson(json),
        );
        return pageResponse;
      } else {
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        throw Exception("network_error".tr());
      }
    } catch (e) {
      throw Exception("general_error".tr());
    }
  }

  Future<PageResponse<Order>> findOrders(
      String keyword, int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();
      final response = await dio.get("${ApiEndpoints.orders_url}/find",
          queryParameters: {'page': page, 'size': size, 'keyword': keyword},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final pageResponse = PageResponse<Order>.fromJson(
          responseData,
          (json) => Order.fromJson(json),
        );
        return pageResponse;
      } else {
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        throw Exception("network_error".tr());
      }
    } catch (e) {
      throw Exception("general_error".tr());
    }
  }

  Future<Order> fetchById(String orderId, BuildContext context) async {
    try {
      final userSession = await UserSession.load();
      final response = await dio.get("${ApiEndpoints.orders_url}/$orderId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        final order = Order.fromJson(response.data['data']);
        return order;
      } else {
        throw Exception(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data["message"] ?? "general_error".tr());
      } else {
        throw Exception("network_error".tr());
      }
    } catch (e) {
      throw Exception("general_error".tr());
    }
  }
}
