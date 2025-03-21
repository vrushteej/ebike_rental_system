import 'package:bike_sharing/home_screen.dart';
import 'package:bike_sharing/signup_screen.dart';
import 'package:bike_sharing/verfication_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  void googleLogin() async {
    AuthService authService = AuthService();
    User? user = await authService.signInWithGoogle();

    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Applying linear gradient from top to bottom
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2FEEB6), Color(0xFFb8f9e6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
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
                        // Navigate to the login screen when the "Log in" text is tapped
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignupScreen()), // Assuming your login screen is LoginScreen
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
              // Main White Card Section (No Margin, Extends to Bottom)
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
                                hintStyle: TextStyle(fontSize: 18, color: Colors.black),
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const Icon(Icons.check_circle, color: Colors.green),
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => VerificationScreen()),
                          );
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
