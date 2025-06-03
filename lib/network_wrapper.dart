import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'shimmer_widget.dart';

class NetworkWrapper extends StatefulWidget {
  final Widget child;

  const NetworkWrapper({super.key, required this.child});

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isConnected ? widget.child : const Scaffold(
      body: ShimmerMessagePlaceholder(),
    );
  }
}
