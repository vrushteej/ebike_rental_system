// landing_page.dart
import 'login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'signup_screen.dart';  // Import your signup screen

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To spread content evenly
          children: [
            // Title at the top
            Padding(
              padding: const EdgeInsets.only(top: 180.0), // Add margin to top
              child: Text(
                'Bike Rental Platform',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center, // Center align the title
              ),
            ),
            // Create Account Button at the bottom
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    )
                ),
                SizedBox(height: 20),
                // Log in text at the bottom
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'Log in',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Log in text color
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          // Action when Log in text is pressed
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
