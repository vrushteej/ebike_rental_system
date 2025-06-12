import 'package:ebike_rental_system/login_screen.dart';
import 'package:ebike_rental_system/profile_page.dart';
import 'package:ebike_rental_system/signup_screen.dart';
import 'package:ebike_rental_system/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'constants/colors.dart';
import 'custom_theme.dart';
import 'landing_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'map_screen.dart';
import 'providers/map_provider.dart';
import 'my_wallet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Bike Rental System',
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        // Add your other routes here
        '/map': (context) => MapScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/chat': (context) => ChatScreen(),
        '/wallet': (context) => MyWalletScreen(),
        '/profile': (context) => ProfilePage(),
      },
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[
          CustomTheme(
            primaryGradient: const LinearGradient(
              colors: [AppColors.primaryColor, AppColors.secondaryColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      ),
    );
  }
}