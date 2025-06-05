import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/model/transaction_model.dart';
import 'package:eswap/model/user_balance.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:eswap/service/auth_interceptor.dart';
import 'package:flutter/cupertino.dart';

class BalanceService {
  final Dio dio = Dio();

  BalanceService() {
    dio.interceptors.add(AuthInterceptor(dio));
  }

  Future<UserBalance> getBalance() async {
    try {
      final userSession = await UserSession.load();
      final response = await dio.get(
        ApiEndpoints.balances_url,
        options: Options(headers: {
          "Authorization": "Bearer ${userSession?.accessToken}",
        }),
      );

      if (response.statusCode == 200) {
        return UserBalance.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (e) {
      throw Exception('Failed to load balance: $e');
    }
  }

  Future<UserBalance> requestWithdraw(
      {required String bankName,
      required String accountNumber,
      required String accountHolder,
      required String password,
      required BuildContext context}) async {
    try {
      final userSession = await UserSession.load();
      final response = await dio.post(
        '${ApiEndpoints.balances_url}/withdraw',
        queryParameters: {
          'bankName': bankName,
          'accountNumber': accountNumber,
          'holder': accountHolder,
          'password': password
        },
        options: Options(headers: {
          "Accept-Language": context.locale.languageCode,
          "Authorization": "Bearer ${userSession?.accessToken}",
        }),
      );
      if (response.statusCode == 200) {
        return UserBalance.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load balance');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        AppAlert.show(
            context: context,
            title: e.response?.data["message"] ?? "general_error".tr(),
            actions: [AlertAction(text: "Tôi đã hiểu")]);
      } else {
        AppAlert.show(
            context: context,
            title: "network_error".tr(),
            actions: [AlertAction(text: "Tôi đã hiểu")]);
      }
      throw Exception('Failed to load balance');
    }
  }

  Future<PageResponse<Transaction>> fetchTransactions(
      int page, int size, BuildContext context) async {
    print("CHECK");
    try {
      final userSession = await UserSession.load();
      final response =
          await dio.get("${ApiEndpoints.balances_url}/transactions",
              queryParameters: {
                'page': page,
                'size': size,
              },
              options: Options(headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${userSession!.accessToken}",
              }));

      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          final responseData = response.data['data'];
          final pageResponse = PageResponse<Transaction>.fromJson(
              responseData, (json) => Transaction.fromJson(json));
          return pageResponse;
        } else {
          throw Exception("no_result_found".tr());
        }
      } else {
        
        throw Exception(response.data['message']);
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

  Future<PageResponse<UserBalance>> fetchBalances(bool isRequestWithdrawal,
      int page, int size, BuildContext context) async {
    try {
      final userSession = await UserSession.load();
      String url = (isRequestWithdrawal)
          ? "${ApiEndpoints.admin_url}/balances/request-withdrawal"
          : "${ApiEndpoints.admin_url}/balances";
      final response = await dio.get(url,
          queryParameters: {
            'page': page,
            'size': size,
          },
          options: Options(headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));
      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          print("1 $response");
          final responseData = response.data['data'];
          final pageResponse = PageResponse<UserBalance>.fromJson(
              responseData, (json) => UserBalance.fromJson(json));

          print("2");
          return pageResponse;
        } else {
          throw Exception("no_result_found".tr());
        }
      } else {
        
        throw Exception(response.data['message']);
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

  Future<void> acceptWithdrawal(int userId, BuildContext context) async {
    try {
      final userSession = await UserSession.load();
      await dio
          .put(
            "${ApiEndpoints.admin_url}/balances/accept-withdrawal/$userId",
            options: Options(
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${userSession!.accessToken}"
              },
            ),
          )
          .catchError((error) => print("follow error"));
    } on DioException catch (e) {
      if (e.response != null) {
       
      } else {
       
      }
    }
  }
}
