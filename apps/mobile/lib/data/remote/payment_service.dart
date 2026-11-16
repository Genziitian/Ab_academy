import 'dart:async';

import 'repositories.dart';
import '../../l10n/strings.dart';

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

/// Enrols a student through the `checkout` Edge Function.
///
/// The Play build does not take payments in the app: Google Play's Payments
/// policy requires Play Billing for digital courses, so students buy on the
/// website. The Razorpay SDK was removed from the app for that reason (it
/// also added NFC, phone-state and biometric permissions). Only the server's
/// test checkout still completes here; a real payment is refused.
///
/// The Razorpay version of this file is in git history (commit 1f46228) if
/// in-app payments ever come back alongside Play Billing.
class PaymentService {
  void dispose() {}

  /// Throws [CheckoutException] with a message fit for the student when the
  /// server refuses or a real payment would be needed.
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

    throw CheckoutException(tx.paymentFailedNothingCharged);
  }
}
