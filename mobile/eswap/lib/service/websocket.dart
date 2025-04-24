import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? stompClient;
  String? accessToken;
  Function(String)? onNewPost;
  bool _isSubscribed = false;

  WebSocketService() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken");

    if (accessToken == null || accessToken!.isEmpty) {
      return;
    }

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    stompClient = StompClient(
      config: StompConfig(
        url: ApiEndpoints.ws_url,
        beforeConnect: () async {
          print('🔌 Đang kết nối WebSocket với token...');
          await Future.delayed(Duration(milliseconds: 300));
        },
        onConnect: (frame) {
          print("✅ WebSocket kết nối thành công!");
          onConnect(frame);
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
        if (frame.body != null && onNewPost != null) {
          final String newPost = frame.body!;
          print("📩 New post received: $newPost");
          onNewPost!(newPost);
        }
      },
    );
    _isSubscribed = true;
  }

  void unsubscribe() {
    if (stompClient != null && _isSubscribed) {
      stompClient!.deactivate();
      _isSubscribed = false;
    }
    onNewPost = null;
  }

  void listenForNewPosts(Function(String) callback) {
    onNewPost = callback;
  }
}
