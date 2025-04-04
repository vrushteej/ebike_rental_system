import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiService {
  // Replace with your backend URL
  static const String baseUrl = 'http://localhost:3000';  // Or the deployed URL of your backend

  // Fetch data from your backend
  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final url = Uri.parse('$baseUrl/user/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);  // Return the parsed data
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }

  // Send data to your backend
  Future<Map<String, dynamic>> createUser(Map<String, String> userData) async {
    final url = Uri.parse('$baseUrl/user');

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(userData));

      if (response.statusCode == 201) {
        return json.decode(response.body);  // Return the created user data
      } else {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }
}
