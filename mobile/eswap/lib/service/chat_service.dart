import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:eswap/model/chat_model.dart';
import 'package:eswap/model/message_model.dart';
import 'package:eswap/model/page_response.dart';
import 'package:eswap/presentation/provider/user_session.dart';
import 'package:eswap/presentation/widgets/dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ChatService {
  final dio = Dio();

  Future<PageResponse<Chat>> fetchChats(
      int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();

      final response = await dio.get(ApiEndpoints.chats_url,
          queryParameters: {'page': page, 'size': size},
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));

      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          final responseData = response.data['data'];
          final pageResponse = PageResponse<Chat>.fromJson(
              responseData, (json) => Chat.fromJson(json));
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
    } catch (e, a) {
      
      throw Exception("general_error".tr());
    }
  }

  Future<Chat> fetchChatInfo(int chatPartnerId, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();
      final response = await dio.get("${ApiEndpoints.chats_url}/$chatPartnerId",
          options: Options(headers: {
            "Content-Type": "application/json",
            "Accept-Language": languageCode,
            "Authorization": "Bearer ${userSession!.accessToken}",
          }));

      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          final responseData = response.data['data'];
          final chat = Chat.fromJson(responseData);
          return chat;
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

  Future<PageResponse<Message>> fetchMessages(
      int chatPartnerId, int page, int size, BuildContext context) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();

      final response =
          await dio.get("${ApiEndpoints.chats_url}/$chatPartnerId/messages",
              queryParameters: {'page': page, 'size': size},
              options: Options(headers: {
                "Content-Type": "application/json",
                "Accept-Language": languageCode,
                "Authorization": "Bearer ${userSession!.accessToken}",
              }));

      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          final responseData = response.data['data'];
          final pageResponse = PageResponse<Message>.fromJson(
              responseData, (json) => Message.fromJson(json));
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

  Future<void> sendMessage(
      {required SendMessageRequest sendMessageRequest,
      List<String>? mediaFiles,
      required BuildContext context}) async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final userSession = await UserSession.load();

      if (sendMessageRequest.content != null) {
        FormData formData = FormData.fromMap({
          "message": MultipartFile.fromString(
            jsonEncode(sendMessageRequest.toJsonForSendMessage()),
            filename: 'message.json',
            contentType: DioMediaType('application', 'json'),
          ),
        });
        dio.post(
          ApiEndpoints.chats_url,
          data: formData,
          options: Options(
            headers: {
              "Content-Type": "application/json",
              "Accept-Language": languageCode,
              "Authorization": "Bearer ${userSession!.accessToken}",
            },
          ),
        );
      } else {
        if (mediaFiles != null && mediaFiles.isNotEmpty) {
          List<MultipartFile> mediaFileList = [];
          List<String> compressedFilePaths = [];
          for (String filePath in mediaFiles) {
            final tempDir = await getTemporaryDirectory();
            final targetPath =
                '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';

            final compressedFile =
                await FlutterImageCompress.compressAndGetFile(
              filePath,
              targetPath,
              quality: 70,
            );
            if (compressedFile != null) {
              mediaFileList.add(
                await MultipartFile.fromFile(
                  compressedFile.path,
                  filename: compressedFile.path.split('/').last,
                ),
              );
              compressedFilePaths.add(compressedFile.path);
            }
          }

          FormData formData = FormData.fromMap({
            "message": MultipartFile.fromString(
              jsonEncode(sendMessageRequest.toJsonForSendMessage()),
              filename: 'message.json',
              contentType: DioMediaType('application', 'json'),
            ),
            "mediaFiles": mediaFileList,
          });
          await dio.post(
            ApiEndpoints.chats_url,
            data: formData,
            options: Options(headers: {
              "Authorization": "Bearer ${userSession!.accessToken}",
            }),
          );
          // Xoá hết các file nén
          for (var path in compressedFilePaths) {
            final compressedFile = File(path);
            if (await compressedFile.exists()) {
              await compressedFile.delete();
            }
          }
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        
      } else {
       
      }
    } catch (e) {
      
    }
  }

  Future<void> markAsRead(int chatPartnerId) async {
    try {
      final dio = Dio();
      final userSession = await UserSession.load();
      dio
          .put(
            "${ApiEndpoints.chats_url}/$chatPartnerId",
            options: Options(
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${userSession!.accessToken}"
              },
            ),
          )
          .catchError((error) => print("mark read message error"));
    } catch (e) {
      print("markAsRead error: ${e.toString()}");
    }
  }
}
