// lib/core/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/flavor_config.dart';
import 'token_storage.dart';

class SocketService {
  SocketService._();
  static final SocketService instance = SocketService._();

  io.Socket? _socket;

  void connect() {
    _socket = io.io(
      FlavorConfig.instance.socketUrl,  // ← reads from flavor
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': TokenStorage.instance.token})
          .build(),
    );
    _socket!.connect();
  }

  void on(String event, Function(dynamic) handler) => _socket?.on(event, handler);
  void emit(String event, dynamic data) => _socket?.emit(event, data);
  void off(String event) => _socket?.off(event);
  void disconnect() => _socket?.disconnect();
}
