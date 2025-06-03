import 'package:ebike_rental_system/payment_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'api_service.dart';
import 'main.dart';

class PlansScreen extends StatefulWidget {
  final String userId; // User ID to identify the user
  const PlansScreen({super.key, required this.userId});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late Razorpay _razorpay;
  late double _selectedAmount;
  late String _selectedPaymentMethod;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    // Initialize Razorpay instance
    _razorpay = Razorpay();

    // Add listeners for payment success and failure
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    ApiService().fetchUserData(context, widget.userId).then((data) {
      setState(() {
        userData = data;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Remove listeners
    _razorpay.clear();
  }

  // Payment success handler
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
                  top: MediaQuery.of(context).size.height * 0.06,
                  bottom: MediaQuery.of(context).size.height * 0.04,
                  left: MediaQuery.of(context).size.width * 0.06,
                  right: MediaQuery.of(context).size.width * 0.06,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),

                    // Title
                    const Text(
                      "Plans",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.025),

                  // Subscription Plans
                  PlanCard(
                    title: "1-Day",
                    price: "₹45",
                    priceDetail: "/day",
                    description: "Chosen by 50% of Users",
                    features: [
                      "Real-time GPS tracking",
                      "24/7 customer support",
                      "Free Repairs",
                    ],
                    buttonText: "Select 1-Day Plan",
                    isPopular: true,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.018),
                  PlanCard(
                    title: "1-Week",
                    price: "₹38",
                    priceDetail: "/day",
                    description: "All Daily features",
                    features: [
                      "Discounted Ride-Extensions",
                      "Portable Charger",
                    ],
                    buttonText: "Select 1-Week Plan",
                    isPopular: false,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.018),
                  PlanCard(
                    title: "1-Month",
                    price: "₹29",
                    priceDetail: "/day",
                    description: "All Weekly features",
                    features: [
                      "Priority Access",
                      "Maintenance Support",
                    ],
                    buttonText: "Select 1-Month Plan",
                    isPopular: false,
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Plan Card Widget ------------------
class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String priceDetail;
  final String description;
  final List<String> features;
  final String buttonText;
  final bool isPopular;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.priceDetail,
    required this.description,
    required this.features,
    required this.buttonText,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: isPopular ? Colors.teal.shade400 : Colors.grey.shade400, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade400.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Most Popular",
                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),

          // Price
          Row(
            children: [
              Text(
                price,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.greenAccent[400]),
              ),
              const SizedBox(width: 5),
              Text(priceDetail, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 5),

          // Description
          Text(
            description,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 10),

          // Features List
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.teal.shade400, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Select Plan Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              _PlansScreenState()._openRazorpay(double.parse(price.replaceAll('₹', '').replaceAll(',', '')), title);
            },
            child: Center(
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
