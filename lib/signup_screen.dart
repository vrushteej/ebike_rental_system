import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ebike_rental_system/verfication_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'login_screen.dart';
import 'main.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SignupScreenState();
  }
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Error messages
  String? emailError;
  String? phoneError;

  bool _obscureText=true;

  // Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    // Simple regex to check email validity
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Validate phone number
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }
    // Check if phone number has exactly 10 digits
    final regex = RegExp(r'^[0-9]{10}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  // // Validate first name
  // String? validateFirstName(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'First name cannot be empty';
  //   }
  //   return null;
  // }
  //
  // // Validate last name
  // String? validateLastName(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Last name cannot be empty';
  //   }
  //   return null;
  // }

  // Sign up method
  void signUp(BuildContext context) async {
    // Validate email and phone before proceeding
    setState(() {
      emailError = validateEmail(emailController.text);
      phoneError = validatePhone(phoneController.text);
    });

    // Early exit if there are validation errors
    if (emailError != null || phoneError != null) {
      print("Email or Phone validation failed.");
      return; // Do not proceed if there are validation errors
    }

    print("Email: ${emailController.text} and Phone: ${phoneController.text}");

    var result = await ApiService().signUp(
      emailController.text,
      phoneController.text,
      passwordController.text,
    );

    if (result['status'] == 'success') {
      String userId = result['userId'];
      String token = result['token'];
      print("User ID: $userId");
      if (userId.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerificationScreen(userId: userId, token: token)),
        );
      } else {
        print("User ID is missing in response.");
      }
    } else {
      // Show error message
      String errorMessage = result['message'] ?? 'Signup failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
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
                    GestureDetector(
                      onTap: () {
                        // Navigate to the login screen when the "Log in" text is tapped
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()), // Assuming your login screen is LoginScreen
                        );
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(
                          'Sign up',
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
                  ],
                ),
              ),

              // Main White Card Section
              Form(
                key: _formKey,
                child: Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 45),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                    ),
                    child: Column(
                      children: [
                        // First Name Field
                        // TextFormField(
                        //   controller: firstNameController,
                        //   validator: validateFirstName,
                        //   decoration: InputDecoration(
                        //     hintText: 'First Name',
                        //     border: InputBorder.none,
                        //     errorText: firstNameError,
                        //   ),
                        //   keyboardType: TextInputType.name,
                        // ),
                        // Divider(color: Colors.grey),
                        // SizedBox(height: 16),
                        //
                        // // Last Name Field
                        // TextFormField(
                        //   controller: lastNameController,
                        //   validator: validateLastName,
                        //   decoration: InputDecoration(
                        //     hintText: 'Last Name',
                        //     border: InputBorder.none,
                        //     errorText: lastNameError,
                        //   ),
                        //   keyboardType: TextInputType.name,
                        // ),
                        // Divider(color: Colors.grey),
                        // SizedBox(height: 16),

                        // Email Field
                        TextFormField(
                          controller: emailController,
                          validator: validateEmail,
                          decoration: InputDecoration(
                            hintText: 'Email (Eg. xyz@gmail.com)',
                            border: InputBorder.none,
                            errorText: emailError,
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        Divider(color: Colors.grey),
                        SizedBox(height: 16),

                        // Phone Number Field
                        Row(
                          children: [
                            Text(
                              '+91',
                              style: TextStyle(fontSize: 18),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: phoneController,
                                validator: validatePhone,
                                decoration: InputDecoration(
                                  hintText: 'Phone no. (Eg. 12345 67890)',
                                  border: InputBorder.none,
                                  errorText: phoneError,
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey),
                        SizedBox(height: 16),

                        TextField(
                          controller: passwordController,
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
                        Divider(color: Colors.grey),
                        SizedBox(height: 16),

                        Text(
                          'Sign up with your e-mail and phone number',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const Spacer(),

                        // Sign up Button
                        ElevatedButton(
                          onPressed: () {
                            signUp(context); // Call the sign-up method
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
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
