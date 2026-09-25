import 'package:flutter/material.dart';

/// PayPal webview screen — deprecated in favour of Stripe Payment Links.
/// Kept as a stub so existing navigation references don't break.
class PaypalWebviewScreen extends StatelessWidget {
  final String approvalUrl;
  final String orderId;

  const PaypalWebviewScreen({
    super.key,
    required this.approvalUrl,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: const Center(
        child: Text('PayPal payments coming soon.'),
      ),
    );
  }
}
