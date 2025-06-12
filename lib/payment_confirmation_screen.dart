// lib/payment_confirmation_screen.dart

import 'package:ebike_rental_system/my_wallet_screen.dart';
import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'package:intl/intl.dart'; // For date formatting

class PaymentConfirmationScreen extends StatelessWidget {
  final String paymentId;
  final String userId;
  final double amount;
  final String paymentMethod;

  const PaymentConfirmationScreen({
    Key? key,
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent[400],
        title: const Text('Payment Confirmation', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Transaction Details
            buildDetailRow("Transaction ID:", paymentId),
            buildDetailRow("Date:", formattedDate),
            buildDetailRow("Payment Method:", paymentMethod),
            buildDetailRow("Total Amount:", "₹${amount.toStringAsFixed(2)}"),

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[400],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyWalletScreen()),
                      (route) => false,
                );
              },
              child: const Text('My Wallet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
