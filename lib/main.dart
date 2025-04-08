import 'package:ebike_rental_system/map_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'landing_page.dart';

void main() async {
  print('Before firebase initialization');
  WidgetsFlutterBinding.ensureInitialized();
  print('Before try-except block');
  print('Initializing Firebase...');
  await Firebase.initializeApp();  // Ensure Firebase is initialized before running the app
  print('Firebase Initialized');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Bike Rental System',
      home: LandingPage(),
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          CustomTheme( // Add gradient theme
            primaryGradient: const LinearGradient(
              colors: [Color(0xFF2FEEB6), Color(0xFFb8f9e6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTheme extends ThemeExtension<CustomTheme> {
  final LinearGradient primaryGradient;

  const CustomTheme({required this.primaryGradient});

  @override
  CustomTheme copyWith({LinearGradient? primaryGradient}) {
    return CustomTheme(
      primaryGradient: primaryGradient ?? this.primaryGradient,
    );
  }

  @override
  CustomTheme lerp(CustomTheme? other, double t) {
    if (other is! CustomTheme) return this;
    return CustomTheme(
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
    );
  }
}