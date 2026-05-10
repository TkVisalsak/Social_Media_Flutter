import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../data/providers/local_storage.dart';

/// Wraps the Socket.io connection for realtime messaging & notifications.
///
/// The backend uses Socket.io (see backend/src — messages + notifications are
/// pushed over sockets). One [SocketService] instance is created in
/// `InitialBinding` as a permanent singleton; UI controllers consume the
/// streams it exposes.
class SocketService {
  SocketService({String? url}) : _url = url ?? _defaultUrl;

  static const _defaultUrl = 'https://localhost:5001';

  final String _url;
  io.Socket? _socket;

  // ── Public streams ────────────────────────────────────────────
  final _connectionController = StreamController<bool>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  bool get isConnected => _socket?.connected ?? false;

  // ── Lifecycle ─────────────────────────────────────────────────

  /// Connect using the JWT stored in [LocalStorage]. Idempotent — calling
  /// twice in a row is safe.
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = LocalStorage.token;

    _socket = io.io(
      _url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token ?? ''})
          .setExtraHeaders({if (token != null) 'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket!
      ..onConnect((_) => _connectionController.add(true))
      ..onDisconnect((_) => _connectionController.add(false))
      ..onConnectError((err) => _connectionController.addError(err))
      ..on('newMessage', _handleMessage)
      ..on('message', _handleMessage)
      ..on('notification', _handleNotification)
      ..on('typing', _handleTyping)
      ..on('stopTyping', _handleTyping);

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionController.add(false);
  }

  // ── Outgoing events ───────────────────────────────────────────

  void joinConversation(String conversationId) {
    _socket?.emit('joinConversation', {'conversationId': conversationId});
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('leaveConversation', {'conversationId': conversationId});
  }

  void sendTyping(String conversationId, {bool isTyping = true}) {
    _socket?.emit(
      isTyping ? 'typing' : 'stopTyping',
      {'conversationId': conversationId},
    );
  }

  /// Generic emit for events not yet wrapped in a typed method.
  void emit(String event, Map<String, dynamic> data) {
    _socket?.emit(event, data);
  }

  // ── Internal handlers ─────────────────────────────────────────

  void _handleMessage(dynamic raw) {
    final data = _asMap(raw);
    if (data != null) _messageController.add(data);
  }

  void _handleNotification(dynamic raw) {
    final data = _asMap(raw);
    if (data != null) _notificationController.add(data);
  }

  void _handleTyping(dynamic raw) {
    final data = _asMap(raw);
    if (data != null) _typingController.add(data);
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  // Tear-down for tests / hot restart safety.
  Future<void> dispose() async {
    disconnect();
    await _connectionController.close();
    await _messageController.close();
    await _notificationController.close();
    await _typingController.close();
  }
}
