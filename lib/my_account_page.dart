import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'editPhoneNumber.dart';
import 'main.dart';

class MyAccountPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? userData;
  const MyAccountPage({super.key, required this.userId, required this.userData});

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  bool notificationsEnabled = false;
  Map<String, dynamic>? userData;
  String address = '';

  @override
  void initState() {
    super.initState();
    if (userData?['address']['street'] != null) {
      address += '${userData?['address']?['street'] ?? ''}, ';
    }
    if (userData?['address']['city'] != null) {
      address += '${userData?['address']?['city'] ?? ''}, ';
    }
    if (userData?['address']['state'] != null) {
      address += '${userData?['address']?['state'] ?? ''}, ';
    }
    if (userData?['address']['country'] != null) {
      address += '${userData?['address']?['country'] ?? ''} - ';
    }
    if (userData?['address']['zipCode'] != null) {
      address += '${userData?['address']?['zipCode'] ?? ''}';
    }
  }

  // Fetch profile data from the backend
  Future<void> _fetchUserData() async {
    try {
      var url = Uri.parse("http://192.168.0.128:3000/user/${widget.userId}"); // Replace with your backend URL
      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      var responseData = jsonDecode(response.body);
      print("Fetch User Response: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        if(responseData['user']!=null){
          setState(() {
            userData = responseData['user'];
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData["message"] ?? "Failed to fetch data")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Function to calculate age from the dob (date of birth)
  int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Applying linear gradient from top to bottom
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<CustomTheme>()!.primaryGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(), // Add padding to the whole body for consistent spacing
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align the items from the top
            crossAxisAlignment: CrossAxisAlignment.start, // Align the children (icon and text) to the left
            children: [
              // Icon and My Account Section
              Container(
                // Adjust the padding here if necessary
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.08,
                  bottom: MediaQuery.of(context).size.height * 0.03,
                  left: MediaQuery.of(context).size.width * 0.1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'My Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.016),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
                  ),
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.02,
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    children: [
                      buildMenuItem('Phone Number', userData?['phone'] ?? ''),
                      buildMenuItem('Address', address),
                      buildMenuItem('Language', 'English'),
                      buildMenuItem('Age',
                          userData?['dob'] != null
                              ? calculateAge(DateTime.parse(userData!['dob'])).toString()
                              : ''),
                      buildMenuItem('Ride History', ''),
                      buildMenuItem('Notification', '')
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

  Widget buildMenuItem(String title, String value) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          subtitle: value.isNotEmpty
              ? Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.004),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.deepPurple[700],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ) : null,
          trailing: title == 'Notification'
            ? Switch(
              value: notificationsEnabled,
              activeColor: Colors.deepPurple,
              onChanged: (bool value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            )
            : const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),
          onTap: () async {
            // if (title == 'Phone Number') {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => EditPhoneNumberPage(
            //           userId: widget.userId,
            //           currentPhoneNumber: userData?['phone'] ?? '',
            //         ),
            //       ),
            //     ).then((_) => _fetchUserData()); // Refresh on return
            //   }
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.006),
          child: const Divider(height: 1),
        ),
      ],
    );
  }
}
