import 'dart:convert';
import 'package:ebike_rental_system/chat_screen.dart';
import 'package:ebike_rental_system/login_screen.dart';
import 'package:ebike_rental_system/map_screen.dart';
import 'package:ebike_rental_system/my_wallet_screen.dart';
import 'package:ebike_rental_system/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:ebike_rental_system/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'custom_theme.dart';
import 'main.dart';
import 'my_account_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;
  Map<String, dynamic>? userData;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String userId = '';

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false).userId;
    ApiService().fetchUserData(context, userId).then((data) {
      setState(() {
        userData = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Applying linear gradient from top to bottom
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<CustomTheme>()!.primaryGradient,
        ),
        child: Column(
          children: [
            // Top Profile Section with Gradient
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05,
                  bottom: MediaQuery.of(context).size.height*0.032),
              child: Column(
                children: [
                  // Log Out Button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.black),
                      onPressed: () async {
                        await _storage.deleteAll();
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        userProvider.clearUserId();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Profile Icon
                  CircleAvatar(
                    radius: 30, // Slightly smaller inner circle for the icon
                    backgroundColor: Colors.black, // Set black background for the inner circle
                    child: Icon(
                      Icons.person,
                      size: 42, // Reduce the size of the icon
                      color: Colors.white, // White icon color
                    ),
                  ),
                  const SizedBox(height: 12),
                  // User Name
                  Text(
                    userData != null
                        ? (userData?['firstName'] != null || userData?['lastName'] != null
                        ? '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}'.trim()
                        : '${userData?['email']}')
                        : 'User',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  children: [
                    buildMenuItem('My Account'),
                    buildMenuItem('My Wallet', trailing: const Text(
                      '₹ 10.50',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )),
                    buildMenuItem('My Statistics'),
                    buildMenuItem('Support'),
                    buildMenuItem('Settings'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Navigate to different screens based on the selected index
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyWalletScreen()));
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          _buildNavItem(Icons.home, 0),
          _buildNavItem(Icons.chat_bubble_outline, 1),
          _buildNavItem(Icons.attach_money, 2),
          _buildNavItem(Icons.person_outline, 3),
        ],
      ),
    );
  }

  // Menu Item Builder
  Widget buildMenuItem(String title, {Widget? trailing}) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
            ),
          ),
          trailing: trailing,
          onTap: () {
            if (title == 'My Account') {
              // Navigate to the MyAccountPage and pass the userId
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyAccountPage(
                    userId: userId,
                    userData: userData,
                  ),
                ),
              );
            }
          },
        ),
        const Divider(height: 1, color: Colors.black12),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          if (_selectedIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.tealAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
      label: '',
    );
  }
}