// Native (Android / iOS) — real Razorpay SDK
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Wraps the Razorpay plugin lifecycle for Android/iOS.
class RazorpayController {
  final Future<void> Function(Map<String, String?> response) onSuccess;
  final void Function(String message) onError;
  final void Function(String walletName) onWallet;

  late final Razorpay _razorpay;

  RazorpayController({
    required this.onSuccess,
    required this.onError,
    required this.onWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);
  }

  void _onSuccess(PaymentSuccessResponse r) {
    onSuccess({
      'orderId': r.orderId,
      'paymentId': r.paymentId,
      'signature': r.signature,
    });
  }

  void _onError(PaymentFailureResponse r) => onError(r.message ?? '');
  void _onWallet(ExternalWalletResponse r) => onWallet(r.walletName ?? '');

  void open(Map<String, dynamic> options) => _razorpay.open(options);

  void dispose() => _razorpay.clear();
}
