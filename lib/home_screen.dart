import 'package:flutter/material.dart';
import 'package:bike_sharing/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});


  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen>{
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Selected: $_selectedIndex",
          style: const TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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