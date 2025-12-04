import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:BookCLUB/config/api_config.dart';

class ChatWebSocketService {
  WebSocketChannel? _channel;

  // Callbacks
  Function(dynamic data)? onMessage;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(dynamic error)? onError;

  bool _isConnecting = false;
  bool _manuallyClosed = false;
  int _chatId = 0;

  // StreamController BROADCAST para poder ter múltiplos listeners
  final StreamController<dynamic> _controller =
      StreamController<dynamic>.broadcast();

  /// Stream final que será consumida no TopicPage
  Stream<dynamic> get messagesStream => _controller.stream;

  // ---------------------------
  // CONECTAR
  // ---------------------------
  void connect(int chatId) {
    _chatId = chatId;
    _manuallyClosed = false;

    if (_isConnecting) return;
    _isConnecting = true;

    final url = "${ApiConfig.websocketBase}/ws/chat/$chatId/";
    print("🔌 Conectando WebSocket em: $url");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (event) {
          dynamic data;

          try {
            data = jsonDecode(event);
          } catch (_) {
            data = event;
          }

          // Dispara callbacks
          onMessage?.call(data);

          // Envia para o StreamController
          if (!_controller.isClosed) {
            _controller.add(data);
          }
        },
        onDone: () {
          print("🔌 WebSocket desconectado.");
          onDisconnected?.call();

          if (!_manuallyClosed) {
            print("🔄 Tentando reconectar...");
            reconnect();
          }
        },
        onError: (error) {
          print("❌ Erro no WebSocket: $error");
          onError?.call(error);

          if (!_manuallyClosed) reconnect();
        },
      );

      onConnected?.call();
    } catch (e) {
      print("❌ Falha ao conectar WebSocket: $e");
    } finally {
      _isConnecting = false;
    }
  }

  // ---------------------------
  // RECONEXÃO
  // ---------------------------
  void reconnect() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!_manuallyClosed) connect(_chatId);
  }

  // ---------------------------
  // ENVIAR MENSAGEM
  // ---------------------------
  void sendMessage(Map<String, dynamic> data) {
    if (_channel == null) return;

    try {
      _channel!.sink.add(jsonEncode(data));
    } catch (e) {
      print("❌ Erro ao enviar mensagem: $e");
    }
  }

  // ---------------------------
  // DESCONECTAR
  // ---------------------------
  void disconnect() {
    _manuallyClosed = true;

    try {
      _channel?.sink.close(ws_status.normalClosure);
    } catch (_) {}

    _channel = null;

    // Não fecha o controller para permitir reconectar
  }
}
