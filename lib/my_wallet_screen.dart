import 'package:ebike_rental_system/api_service.dart';
import 'package:ebike_rental_system/chat_screen.dart';
import 'package:ebike_rental_system/payment_confirmation_screen.dart';
import 'package:ebike_rental_system/plans_screen.dart';
import 'package:ebike_rental_system/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'main.dart';
import 'map_screen.dart';

class MyWalletScreen extends StatefulWidget {
  final String userId; // User ID to identify the user
  const MyWalletScreen({super.key, required this.userId});

  @override
  State<MyWalletScreen> createState() => MyWalletScreenState();
}

class MyWalletScreenState extends State<MyWalletScreen> {
  int _selectedIndex = 2;
  late double _selectedAmount;
  late String _selectedPaymentMethod;
  late Razorpay _razorpay;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    ApiService().fetchUserData(context, widget.userId).then((data) {
      setState(() {
        userData = data;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Success: ${response.paymentId}");

    // Retrieve payment details
    String paymentId = response.paymentId!;
    String orderId = response.orderId!;
    String signature = response.signature!;

    // Call both createPaymentOrder and verifyPayment after successful payment
    ApiService().createPaymentOrder(widget.userId, 'rideId123', paymentId).then((orderResponse) {
      if (orderResponse['success']) {
        print("Payment order created successfully on the backend.");

        // Now verify the payment after the order is created
        ApiService().verifyPayment(paymentId, orderId, signature).then((verifyResponse) {
          if (verifyResponse['success']) {
            print("Payment verified successfully.");

            // After verification, navigate to the confirmation screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentConfirmationScreen(
                  paymentId: paymentId,
                  userId: widget.userId,
                  amount: _selectedAmount,
                  paymentMethod: _selectedPaymentMethod ?? 'Razorpay',
                ),
              ),
            );
          } else {
            print("Payment verification failed.");
          }
        }).catchError((error) {
          print("Error verifying payment: $error");
        });
      } else {
        print("Error creating payment order on the backend.");
      }
    }).catchError((error) {
      print("Error calling createPaymentOrder API: $error");
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
    setState(() {
      _selectedPaymentMethod = response.walletName ?? 'Wallet';
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Failure: ${response.message}");
    // Log the response to check its structure
    print("Payment Failure Response: ${response.toString()}");

    if (response.error != null) {
      // Handle the error response here
      print("Error: ${response.error}");
    }
  }

  void _openRazorpay(double amount, String? description) {
    _selectedAmount = amount;
    var options = {
      'key': dotenv.env['RAZORPAY_KEY_ID']!, // Ensure key is loaded correctly
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Ebike Rental',
      'description': description,
      'prefill': {
        'contact': userData?['phone'] ?? '',
        'email': userData?['email'] ?? '',
      },
      'external': {
        'wallets': ['googlepay', 'paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            // Applying linear gradient from top to bottom
            decoration: BoxDecoration(
              gradient: Theme.of(context).extension<CustomTheme>()!.primaryGradient,
            ),
          ),

          Scrollbar(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.12,
                  bottom: MediaQuery.of(context).size.height * 0.05,
                  left: MediaQuery.of(context).size.width * 0.06,
                  right: MediaQuery.of(context).size.width * 0.06,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Back Button
                // IconButton(
                //   icon: const Icon(Icons.arrow_back, color: Colors.black),
                //   onPressed: () => Navigator.pop(context),
                // ),
                // Title
                const Text(
                  "My Wallet",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                // Wallet Card
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.036,
                    horizontal: MediaQuery.of(context).size.width * 0.05
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Available Balance",
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "₹1000",
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.tealAccent[400]),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent[400],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PlansScreen(userId: widget.userId)));
                            },
                            child: const Text("+ Top Up"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Weekly Pass Section
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.tealAccent[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Weekly Pass",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const Text(
                              "₹24.99",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const Text(
                              "Unlimited rides • 7 days",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Color(0xFF2FEEB6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _openRazorpay(24.99, "Weekly Pass"),
                                child: const Text(
                                  "Purchase",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Payment Methods
                // PaymentOption(title: "UPI"),
                // PaymentOption(title: "Cards"),
                // PaymentOption(title: "Netbanking"),
                //
                // const SizedBox(height: 20),

                // Recent Transactions
                RecentTransactions(),
              ],
            ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Navigate to different screens based on the selected index
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(userId: widget.userId,)));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(userId: widget.userId)));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId)));
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

// ---------------- Recent Transactions ------------------
class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Transactions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          transactionItem("Weekly Pass", "-₹24.99", "Feb 9, 2025", Colors.red),
          transactionItem("Top Up", "+₹50.00", "Feb 8, 2025", Color(0xFF2FEEB6)),
        ],
      ),
    );
  }

  Widget transactionItem(String title, String amount, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Text(
            amount,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

