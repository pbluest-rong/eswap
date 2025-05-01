import 'dart:async';
import 'package:eswap/core/constants/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  StompClient? stompClient;
  String? accessToken;
  bool _isSubscribed = false;

  final _postStreamController = StreamController<String>.broadcast();
  final _messageStreamController = StreamController<String>.broadcast();

  Stream<String> get postStream => _postStreamController.stream;
  Stream<String> get messageStream => _messageStreamController.stream;

  WebSocketService._internal();

  static Future<WebSocketService> getInstance() async {
    if (!_instance._isSubscribed) {
      await _instance._initialize();
    }
    return _instance;
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken");

    if (accessToken == null || accessToken!.isEmpty) return;

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    stompClient = StompClient(
      config: StompConfig(
        url: ApiEndpoints.ws_url,
        beforeConnect: () async {
          print('🔌 Đang kết nối WebSocket...');
          await Future.delayed(Duration(milliseconds: 300));
        },
        onConnect: onConnect,
        onWebSocketError: (error) => print("❌ WebSocket Error: $error"),
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
        connectionTimeout: Duration(seconds: 5),
        heartbeatIncoming: Duration.zero,
        heartbeatOutgoing: Duration.zero,
        reconnectDelay: Duration(milliseconds: 5000),
      ),
    );

    stompClient?.activate();
  }

  void onConnect(StompFrame frame) {
    print("✅ WebSocket connected: ${frame.headers['session']}");

    stompClient?.subscribe(
      destination: '/user/queue/new-posts',
      headers: {'Authorization': 'Bearer $accessToken'},
      callback: (frame) {
        if (frame.body != null) {
          _postStreamController.add(frame.body!);
        }
      },
    );

    stompClient?.subscribe(
      destination: '/user/queue/new-message',
      headers: {'Authorization': 'Bearer $accessToken'},
      callback: (frame) {
        if (frame.body != null) {
          _messageStreamController.add(frame.body!);
        }
      },
    );

    _isSubscribed = true;
  }

  void unsubscribe() {
    if (_isSubscribed && stompClient != null) {
      stompClient!.deactivate();
      _isSubscribed = false;
    }

    _postStreamController.close();
    _messageStreamController.close();
  }
}
