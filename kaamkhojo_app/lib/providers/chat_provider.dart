import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/message.dart';
import '../services/message_service.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class ChatProvider extends ChangeNotifier {
  final _messageService = MessageService();

  io.Socket? _socket;
  final Map<String, List<MessageModel>> _messages = {};
  String? _currentBookingId;
  bool _connected = false;
  bool _loading = false;
  String? _typingUserId;

  List<MessageModel> get messages =>
      _messages[_currentBookingId] ?? [];
  bool get connected => _connected;
  bool get loading => _loading;
  String? get typingUserId => _typingUserId;

  Future<void> connectAndJoin(String bookingId) async {
    _currentBookingId = bookingId;
    _loading = true;
    notifyListeners();

    // Load existing messages from REST API
    try {
      final msgs = await _messageService.getMessages(bookingId);
      _messages[bookingId] = msgs;
    } catch (_) {}

    // Connect socket
    final token = await ApiService.instance.getAccessToken();
    _socket ??= io.io(
      AppConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    if (!_connected) {
      _socket!.connect();
      _socket!.on('connect', (_) {
        _connected = true;
        notifyListeners();
      });
      _socket!.on('disconnect', (_) {
        _connected = false;
        notifyListeners();
      });
    }

    _socket!.emit('join_booking_room', {'bookingId': bookingId});

    _socket!.on('message_received', (data) {
      final msg = MessageModel.fromJson(data as Map<String, dynamic>);
      _messages[bookingId] = [...(_messages[bookingId] ?? []), msg];
      notifyListeners();
    });

    _socket!.on('typing_indicator', (data) {
      final d = data as Map<String, dynamic>;
      _typingUserId = d['isTyping'] == true ? d['userId'] as String : null;
      notifyListeners();
    });

    _loading = false;
    notifyListeners();
  }

  void sendMessage(String bookingId, String message) {
    if (message.trim().isEmpty) return;
    _socket?.emit('send_message', {'bookingId': bookingId, 'message': message});
  }

  void sendTyping(String bookingId, {required bool isTyping}) {
    _socket?.emit('typing', {'bookingId': bookingId, 'isTyping': isTyping});
  }

  void disconnect() {
    _socket?.disconnect();
    _connected = false;
    _currentBookingId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
