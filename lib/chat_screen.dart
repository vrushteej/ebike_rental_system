import 'package:ebike_rental_system/map_screen.dart';
import 'package:ebike_rental_system/my_wallet_screen.dart';
import 'package:ebike_rental_system/profile_page.dart';
import 'package:flutter/material.dart';
import 'chat_socket_service.dart';
import 'get_chatbot_response.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'main.dart'; // Import the chatbot response function

class ChatScreen extends StatefulWidget {
  final String userId; // User ID to identify the user
  const ChatScreen({super.key, required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // Stores messages
  late ChatSocketService _chatSocket;

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    _chatSocket = ChatSocketService();
    _chatSocket.initSocket();

    _chatSocket.socket.on('chat_to_flutter', (data) {
      setState(() {
        _messages.add({"sender": "bot", "message": data['response']});
      });
    });
  }


  void _sendMessage() async {
    String message = _controller.text.trim();
    if (message.isEmpty) return;

    // Add user message to the list
    setState(() {
      _messages.add({"sender": "user", "message": message});
    });

    _controller.clear(); // Clear input field

    // Get chatbot response
    // String response = await getChatbotResponse(message);
    //
    // // Add bot response after a short delay
    // Future.delayed(const Duration(milliseconds: 500), () {
    //   setState(() {
    //     _messages.add({"sender": "bot", "message": response});
    //   });
    // });


      _chatSocket.sendMessage(message);
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Applying linear gradient from top to bottom
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<CustomTheme>()!.primaryGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SizedBox(height: MediaQuery.of(context).size.height * 0.042),
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.08,
                  bottom: MediaQuery.of(context).size.height * 0.03,
                  left: MediaQuery.of(context).size.width * 0.1,
                ),
                child: Row(
                  spacing: 32,
                  children: [
                    Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.width * 0.032),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      // Chat messages with Scrollbar
                      Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              bool isUser = message["sender"] == "user";

                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(12),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                      MediaQuery.of(context).size.width *
                                          0.7),
                                  decoration: BoxDecoration(
                                    color: isUser ? Colors.tealAccent : Colors.white, // Ensure white for non-user messages
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    message["message"]!,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Message input field
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.016),
                                    hintText: "Type your message...",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                            FloatingActionButton(
                              onPressed: _sendMessage,
                              backgroundColor: Color(0xFF2FEEB6),
                              mini: true,
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 25,  // Increase the icon size (you can adjust this value)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Navigate to different screens based on the selected index
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(userId: widget.userId,)));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyWalletScreen(userId: widget.userId,)));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId,)));
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.chat_bubble_outline, 1),
          _buildNavItem(Icons.attach_money, 2),
          _buildNavItem(Icons.person_outline, 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          if (_selectedIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.tealAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
      label: '',
    );
  }
  @override
  void dispose() {
    _chatSocket.dispose();
    super.dispose();
  }
}
