import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String planId;
  final String planLabel;
  final String priceLabel;
  final String priceSub;

  const CheckoutScreen({
    super.key,
    required this.planId,
    required this.planLabel,
    required this.priceLabel,
    required this.priceSub,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _processing = false;
  bool _linkOpened = false;

  Future<void> _pay() async {
    setState(() => _processing = true);
    await PaymentService().openPaymentLink(planId: widget.planId);
    if (!mounted) return;
    setState(() {
      _processing = false;
      _linkOpened = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(widget.planLabel),
  leading: IconButton(
    icon: const Icon(Icons.close),
    onPressed: () => Navigator.pop(context, false),
  ),
),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
           Text(widget.priceLabel,
    style: const TextStyle(
        fontSize: 32, fontWeight: FontWeight.bold)),
const SizedBox(height: 4),
Text('${widget.priceLabel} USD', style: const TextStyle(fontSize: 14, color: Colors.grey)),
const SizedBox(height: 8),
Text(widget.priceSub,
    style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _processing ? null : _pay,
                  child: _processing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Pay Now',
                          style: TextStyle(fontSize: 18)),
                ),
              ),
              if (_linkOpened) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('I have completed payment',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}