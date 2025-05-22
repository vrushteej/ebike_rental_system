import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService {
  late IO.Socket _socket;

  void initSocket() {
    _socket = IO.io(
      'https://ccmap-backend.onrender.com', // Replace with your live Node.js URL
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );

    _socket.connect();

    _socket.onConnect((_) {
      print('Connected to Socket.IO server');
    });

    _socket.on('chat_to_flutter', (data) {
      print('Bot replied: ${data['response']}');
      // TODO: update UI or trigger listener
    });

    _socket.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  void sendMessage(String message) {
    _socket.emit('chat_from_flutter', {'message': message});
    print('Sent: $message');
  }

  void dispose() {
    _socket.disconnect();
  }

  IO.Socket get socket => _socket;
}