// Web stub — Razorpay Flutter SDK is not supported on web.
// RazorpayController is a no-op placeholder so the code compiles on web.

class RazorpayController {
  RazorpayController({
    required Future<void> Function(Map<String, String?> response) onSuccess,
    required void Function(String message) onError,
    required void Function(String walletName) onWallet,
  });

  // ignore: avoid_unused_parameters
  void open(Map<String, dynamic> options) {
    throw UnsupportedError(
      'Razorpay native checkout is not supported on Flutter Web. '
      'Please use the mobile app to pay online.',
    );
  }

  void dispose() {}
}
