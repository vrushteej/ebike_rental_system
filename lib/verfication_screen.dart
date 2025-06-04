import 'package:ebike_rental_system/home_screen.dart';
import 'package:ebike_rental_system/map_screen.dart';
import 'package:ebike_rental_system/otp_field.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class VerificationScreen extends StatefulWidget {
  final String userId, token;
  const VerificationScreen({super.key, required this.userId, required this.token});

  @override
  State<StatefulWidget> createState() {
    return _VerificationScreenState();
  }
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final storage = FlutterSecureStorage();

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Widget _buildCodeBox(BuildContext context, int index) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < _focusNodes.length - 1) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          }
        },
      ),
    );
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
                    Text(
                      'Verification',
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
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 45),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) => _buildCodeBox(context, index)),
                      ),
                    SizedBox(height: 20),
                    Text(
                      'Please enter the OTP sent to your phone by SMS to verify your number. The OTP shall be valid for 5 minutes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Text(
                    //   '+91 123 45 67',
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.black,
                    //   ),
                    // ),
                    // SizedBox(height: 10),
                    Text(
                      "Resend OTP",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                    const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          await storage.write(key: 'isLoggedIn', value: 'true');
                          await storage.write(key: 'userId', value: widget.userId);
                          await storage.write(key: 'authToken', value: widget.token);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => MapScreen(userId: widget.userId)),
                                (Route<dynamic> route) => false,
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
                              'Continue',
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
        ],
      ),
    ),
    ),
    );
  }
}

