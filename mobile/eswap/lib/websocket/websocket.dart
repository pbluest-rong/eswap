import 'dart:convert';

import 'package:eswap/core/utils/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? stompClient;
  String? accessToken;

  WebSocketService() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken");
    print("📌 Token từ SharedPreferences: $accessToken");

    if (accessToken == null || accessToken!.isEmpty) {
      print("⚠️ Không tìm thấy accessToken!");
      return;
    }

    // Tạo headers dùng chung
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    stompClient = StompClient(
      config: StompConfig(
        url: ServerInfo.ws_url,
        onConnect: (frame) {
          print("✅ WebSocket kết nối thành công!");
          onConnect(frame);
        },
        beforeConnect: () async {
          print('🔌 Đang kết nối WebSocket với token...');
          await Future.delayed(Duration(milliseconds: 300));
        },
        onWebSocketError: (dynamic error) {
          print("❌ WebSocket Error: $error");
        },
        // Quan trọng: Cấu hình cả 2 loại headers
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        // Bổ sung các cấu hình quan trọng khác
        connectionTimeout: Duration(seconds: 5),
        heartbeatIncoming: Duration(seconds: 0),
        heartbeatOutgoing: Duration(seconds: 0),
        reconnectDelay: Duration(milliseconds: 5000),
        onDebugMessage: (String message) {
          print('STOMP DEBUG: $message');
        },
      ),
    );

    stompClient?.activate();
  }

  void onConnect(StompFrame frame) {
    print("✅ Connected with session: ${frame.headers['session']}");

    stompClient?.subscribe(
      destination: '/user/queue/new-posts',
      headers: {'Authorization': 'Bearer $accessToken'},
      callback: (frame) {
        print("📩 Received message!");
        print("Headers: ${frame.headers}");
        print("Body: ${frame.body}");
      },
    );
    stompClient?.subscribe(
      destination: '/topic/new-post',
      headers: {'Authorization': 'Bearer $accessToken'},
      callback: (frame) {
        if (frame.body != null) {
          Map<String, dynamic> postData = jsonDecode(frame.body!);
          print(postData);
        }
      },
    );
  }
}
