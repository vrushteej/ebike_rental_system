import 'package:flutter/material.dart';
import 'landing_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Bike Rental System',
      // home: MapScreen(userId: ''),
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