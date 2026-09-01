import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Cuida só da conexão WebSocket com o servidor de sinalização local.
/// Não sabe nada sobre WebRTC — apenas envia/recebe mensagens JSON.
class SignalingService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  bool get isConnected => _channel != null;

  /// [serverUrl] deve ser algo como ws://SEU_IP_RADMIN:8080/ws
  Future<void> connect(String serverUrl) async {
    _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    _channel!.stream.listen(
      (raw) {
        try {
          final data = jsonDecode(raw as String) as Map<String, dynamic>;
          _messageController.add(data);
        } catch (_) {
          // ignora mensagens malformadas
        }
      },
      onDone: () {
        _messageController.add({'type': 'disconnected'});
      },
      onError: (_) {
        _messageController.add({'type': 'disconnected'});
      },
    );
  }

  void send(Map<String, dynamic> message) {
    _channel?.sink.add(jsonEncode(message));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
