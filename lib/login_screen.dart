import 'dart:convert';

import 'package:ebike_rental_system/home_screen.dart';
import 'package:ebike_rental_system/signup_screen.dart';
import 'package:ebike_rental_system/verfication_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this for TextInputFormatter
import 'package:http/http.dart' as http;

import 'auth_service.dart';
import 'main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pswdController = TextEditingController();
  bool isPhoneNumberValid = false; // Track validity of the phone number
  bool _obscureText = true; // Track visibility of password

  void googleLogin() async {
    AuthService authService = AuthService();
    User? user = await authService.signInWithGoogle();

    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  // Method to check for valid phone number
  void validatePhoneNumber(String phoneNumber) {
    // Update the isPhoneNumberValid flag based on length and numeric check
    setState(() {
      isPhoneNumberValid = phoneNumber.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phoneNumber);
    });
  }

  Future<void> loginUser() async {
    final String phoneOrEmail = phoneController.text.trim();
    final String password = pswdController.text.trim();

    if (phoneOrEmail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both phone/email and password")),
      );
      return;
    }

    try {
      var url = Uri.parse("http://192.168.0.128:3000/user/login"); // Replace with your backend URL
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phoneOrEmail": phoneOrEmail, "password": password}),
      );

      var responseData = jsonDecode(response.body);
      print("Response: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201 || responseData["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful!")),
        );

        // Navigate to verification screen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerificationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                child: Row(
                  spacing: 32,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Positioned(
                          bottom: -4, // Adjusts the underline position
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 4,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the signup screen when the "Sign up" text is tapped
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignupScreen()),
                        );
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main White Card Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 45),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            '+91',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              style: const TextStyle(fontSize: 18),
                              decoration: const InputDecoration(
                                hintText: '12345 67890',
                                // hintStyle: TextStyle(fontSize: 18, color: Colors.black),
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly, // Only allow digits
                              ],
                              onChanged: (text) {
                                // Validate phone number whenever the user types
                                validatePhoneNumber(text);
                              },
                            ),
                          ),
                          // Conditionally show the tick icon based on validity
                          isPhoneNumberValid
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.check_circle, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: pswdController,
                              obscureText: _obscureText, // Toggle password visibility
                              style: const TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                hintText: 'Enter Password',
                                // hintStyle: const TextStyle(fontSize: 18, color: Colors.black),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText; // Toggle password visibility
                                    });
                                  },
                                ),
                              ),
                              keyboardType: TextInputType.visiblePassword,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 24),
                      const Text(
                        'Log in with your phone number',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const Spacer(),
                      // Log in Button at the Bottom
                      ElevatedButton(
                        onPressed: () {
                          String phoneNumber = phoneController.text.trim();

                          // Validate phone number
                          if (phoneNumber.isEmpty) {
                            // Show an error if the field is empty
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please enter a phone number")),
                            );
                          } else if (!isPhoneNumberValid) {
                            // Show an error if the phone number is invalid
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please enter a valid 10-digit phone number")),
                            );
                          } else {
                            loginUser();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Make button background transparent to show gradient
                          padding: EdgeInsets.symmetric(vertical: 16), // Add vertical padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32), // Rounded corners
                          ),
                          shadowColor: Colors.transparent, // Remove shadow if needed
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2FEEB6), Color(0xFFb8f9e6)], // Your gradient colors
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(32), // Rounded corners
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16), // Button padding
                            alignment: Alignment.center, // Center the text
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black, // Text color
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Log in Button at the Bottom
                      ElevatedButton(
                        onPressed: () {
                          googleLogin(); // Call your googleLogin method
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google_logo.png', // Path to your Google logo image
                                height: 24, // Adjust the size
                                width: 24,  // Adjust the size
                              ),
                              SizedBox(width: 12), // Space between icon and text
                              Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
