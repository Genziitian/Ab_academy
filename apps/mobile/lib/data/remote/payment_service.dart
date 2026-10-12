import 'dart:async';

import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'repositories.dart';

/// What the success screen shows after a purchase.
class PaymentReceipt {
  const PaymentReceipt({
    required this.courseId,
    required this.orderId,
    required this.amountInr,
    required this.method,
    required this.testMode,
  });

  final String courseId;
  final String orderId;
  final int amountInr;
  final String method;

  /// True when nothing was charged (mock data, or the server's test checkout).
  final bool testMode;
}

/// Sells a course: creates the order on the `checkout` Edge Function, takes
/// the payment in Razorpay's native sheet, then has the server verify the
/// signature and enrol the student. The app never marks anything paid itself.
class PaymentService {
  PaymentService() {
    _razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onWallet);
  }

  final _razorpay = Razorpay();
  Completer<PaymentSuccessResponse>? _pending;

  void dispose() => _razorpay.clear();

  /// Runs the whole purchase. Throws [CheckoutException] with a message fit
  /// for the student when the server refuses or the payment fails.
  Future<PaymentReceipt> buy({
    required String courseId,
    required String methodLabel,
  }) async {
    final order = await Repo.checkout({
      'action': 'create',
      'course_id': courseId,
    });
    final orderId = order['order_id'] as String;
    final amount = (order['amount_inr'] as num).toInt();

    if (order['test_mode'] == true) {
      await Repo.checkout({'action': 'complete_test', 'order_id': orderId});
      return PaymentReceipt(
        courseId: courseId,
        orderId: orderId,
        amountInr: amount,
        method: methodLabel,
        testMode: true,
      );
    }

    final prefill = Map<String, dynamic>.from(
      (order['prefill'] as Map?) ?? const {},
    );
    // Opens Razorpay on the method the student picked; they can still switch.
    prefill['method'] = methodLabel.toLowerCase().contains('card')
        ? 'card'
        : 'upi';

    _pending = Completer<PaymentSuccessResponse>();
    _razorpay.open({
      'key': order['key_id'],
      'order_id': order['razorpay_order_id'],
      'amount': amount * 100,
      'currency': order['currency'] ?? 'INR',
      'name': 'Akhand Bharat Academy',
      'description': order['course_title'] ?? 'Crash course',
      'prefill': prefill,
      'theme': {'color': '#2962FF'},
      'retry': {'enabled': true, 'max_count': 2},
    });
    final payment = await _pending!.future;

    await Repo.checkout({
      'action': 'verify',
      'order_id': orderId,
      'razorpay_order_id': payment.orderId,
      'razorpay_payment_id': payment.paymentId,
      'razorpay_signature': payment.signature,
    });

    return PaymentReceipt(
      courseId: courseId,
      orderId: orderId,
      amountInr: amount,
      method: methodLabel,
      testMode: false,
    );
  }

  void _onSuccess(PaymentSuccessResponse response) =>
      _pending?.complete(response);

  void _onError(PaymentFailureResponse response) {
    final cancelled = response.code == Razorpay.PAYMENT_CANCELLED;
    _pending?.completeError(
      CheckoutException(
        cancelled
            ? 'Payment cancelled.'
            : (response.message?.isNotEmpty ?? false)
            ? response.message!
            : 'Payment failed. Nothing was charged.',
      ),
    );
  }

  void _onWallet(ExternalWalletResponse response) {
    // The wallet app finishes the payment; the webhook enrols the student.
    _pending?.completeError(
      CheckoutException(
        'Finishing payment in ${response.walletName ?? 'your wallet'} — '
        'your course unlocks as soon as it is confirmed.',
      ),
    );
  }
}
