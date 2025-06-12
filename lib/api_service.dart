import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://ccmap-backend.onrender.com";

  Future<Map<String, dynamic>> signUp(String email, String phone, String password) async {
    final String apiUrl = '$baseUrl/user/register';

    // Prepare the data to be sent to the server
    final Map<String, String> userData = {
      "email": email,
      "phone": phone,
      "password": password,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      // Decode response body
      var responseData = jsonDecode(response.body);
      Map<String, dynamic> result = {};

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        // Success case
        result['status'] = 'success';
        result['userId'] = responseData['user']['_id'];
        result['token'] = responseData['token'];
      } else {
        // Error case
        result['status'] = 'error';
        result['message'] = responseData["message"] ?? "Signup failed";
      }

      return result;
    } catch (error) {
      Map<String, dynamic> result = {};
      if (error is TimeoutException) {
        result['status'] = 'error';
        result['message'] = 'Request timed out. Please try again.';
      } else if (error is SocketException) {
        result['status'] = 'error';
        result['message'] = 'No internet connection. Please check your network.';
      } else {
        result['status'] = 'error';
        result['message'] = '$error';
      }
      return result;
    }
  }

  // Login API call
  Future<Map<String, dynamic>> loginUser(String email, String phone, String password) async {
    final String apiUrl = '$baseUrl/user/login';

    // Prepare the data to send to the server
    final Map<String, String> loginData = {
      "email": email,
      "phone": phone,
      "password": password,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginData),
      );

      // Decode the response body
      var responseData = jsonDecode(response.body);
      Map<String, dynamic> result = {};

      if (response.statusCode == 200 || response.statusCode == 201 || responseData["success"]) {
        result['status'] = 'success';
        result['userId'] = responseData['userId'];
        result['token'] = responseData['token'];
      } else {
        result['status'] = 'error';
        result['message'] = responseData["message"] ?? "Login failed";
      }

      return result;
    } catch (error) {
      Map<String, dynamic> result = {};
      if (error is TimeoutException) {
        result['status'] = 'error';
        result['message'] = 'Request timed out. Please try again.';
      } else if (error is SocketException) {
        result['status'] = 'error';
        result['message'] = 'No internet connection. Please check your network.';
      } else {
        result['status'] = 'error';
        result['message'] = '$error';
      }
      return result;
    }
  }

  Future<Map<String, dynamic>> createPaymentOrder(String userId, String rideId, String paymentMethod) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payment/create-payment'),
      body: json.encode({
        'userId': userId,
        'rideId': rideId,
        'payment_method': paymentMethod,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);  // Return order details
    } else {
      throw Exception('Failed to create payment order');
    }
  }

  // Fetch User Data (if profile data is null)
  Future<Map<String, dynamic>?> fetchUserData(BuildContext context, String userId) async {
    try {
      var url = Uri.parse("$baseUrl/user/$userId");  // Use baseUrl here
      var response = await http.get(url, headers: {"Content-Type": "application/json"});

      var responseData = jsonDecode(response.body);
      print("Fetch User Response: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        if (responseData['user'] != null) {
          return responseData['user'];
        }
      } else {
        _showError(context, responseData["message"] ?? "Failed to fetch user data");
      }
    } catch (e) {
      _showError(context, "Error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> verifyPayment(String paymentId, String orderId, String signature) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/razorpay/verifyPayment'),
      body: json.encode({
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'razorpay_signature': signature,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);  // Return verification response
    } else {
      throw Exception('Failed to verify payment');
    }
  }

  // Fetch nearest stations using latitude and longitude
  Future<List<dynamic>> findNearestStations(double? latitude, double? longitude) async {
    final url = Uri.parse('$baseUrl/station/all');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data; // Return the list of stations if successful
      } else {
        // Handle non-200 response code
        throw Exception('Failed to fetch nearest stations: ${response.body}');
      }
    } catch (e) {
      // Handle error during the API call
      throw Exception('Error fetching stations: $e');
    }
  }


  // Show error message using a SnackBar
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
