import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getChatbotResponse(String userMessage) async {
  final url = Uri.parse("https://5d6a-183-87-190-240.ngrok-free.app/chat");  // The URL for your Flask API

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode({"message": userMessage}),
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);
    return responseBody["response"];  // The chatbot's response
  } else {
    throw Exception("Failed to get response from chatbot");
  }
}
