import 'package:eventos_da_rep/http/payment_client.dart';
import 'package:eventos_da_rep/models/payment.dart';

class PaymentService {
  final _paymentClient = PaymentClient();

  Future<List<Payment>> getPaymentsByUserIdAndEventId(
    String userId,
    String eventId,
  ) async {
    try {
      return await _paymentClient.getPaymentsByEventIdAndUserId(
        eventId,
        userId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Payment?> getSuccessOrProcessingPayment(
    String userId,
    String eventId,
  ) async {
    List<Payment> payments = await _paymentClient.getPaymentsByEventIdAndUserId(
      eventId,
      userId,
    );

    for (Payment p in payments) {
      if (p.status == PaymentStatus.success ||
          p.status == PaymentStatus.processing) {
        return p;
      }
    }

    return null;
  }

  Future<String> createPayment(String eventId, String userId) async {
    return await _paymentClient.createPaymentIntent(eventId, userId);
  }

  Future<void> refundPayment(Payment payment) async {
    if (payment.status == PaymentStatus.success) {
      await _paymentClient.refund(payment.id);
    } else {
      throw Exception(
        'Não é possível reembolsar um pagamento que está em processamento',
      );
    }
  }

  bool isProcessingPayment(Payment? payment) {
    if (payment == null) {
      return false;
    }

    if (payment.status == PaymentStatus.processing) {
      return true;
    }

    return false;
  }
}
