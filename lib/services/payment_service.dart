import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const String _weeklyUrl =
      'https://buy.stripe.com/9B69AU82K7kT4m2dcf2cg02';
  static const String _monthlyUrl =
      'https://buy.stripe.com/4gM4gA0AigVt05Megj2cg01';
  static const String _yearlyUrl =
      'https://buy.stripe.com/5kQ5kEdn4cFd3hYc8b2cg00';

  Future<void> openPaymentLink({required String planId}) async {
    String url;
    switch (planId) {
      case 'weekly':
        url = _weeklyUrl;
        break;
      case 'monthly':
        url = _monthlyUrl;
        break;
      case 'yearly':
        url = _yearlyUrl;
        break;
      default:
        return;
    }

    final uri = Uri.parse(url);
try {
  await launchUrl(uri, mode: LaunchMode.platformDefault);
} catch (e) {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
  }
}