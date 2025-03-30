import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getChatbotResponse(String userMessage) async {
  final url = Uri.parse("http://10.0.2.2:5001/chat");  // The URL for your Flask API

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
