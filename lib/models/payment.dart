class Payment {
  final String id;
  final String gatewayPaymentId;
  final String gatewayPaymentIntentClientId;
  final int amount;
  final String currency;
  final String userId;
  final String eventId;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? paidAt;

  Payment(
    this.id,
    this.gatewayPaymentId,
    this.gatewayPaymentIntentClientId,
    this.amount,
    this.currency,
    this.userId,
    this.eventId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.paidAt,
  );

  factory Payment.fromJson(dynamic json) {
    PaymentStatus getStatus(String status) {
      switch (status) {
        case 'PENDING':
          return PaymentStatus.pending;
        case 'PROCESSING':
          return PaymentStatus.processing;
        case 'SUCCESS':
          return PaymentStatus.success;
        case 'REFUNDED':
          return PaymentStatus.refunded;
        default:
          return PaymentStatus.failed;
      }
    }

    return Payment(
      json['id'] as String,
      json['gatewayPaymentId'] as String,
      json['gatewayPaymentIntentClientId'] as String,
      json['amount'] as int,
      json['currency'] as String,
      json['userId'] as String,
      json['eventId'] as String,
      getStatus(json['status']),
      DateTime.parse(json['createdAt']),
      DateTime.parse(json['updatedAt']),
      DateTime.parse(json['paidAt']),
    );
  }
}

enum PaymentStatus {
  pending,
  processing,
  success,
  refunded,
  failed,
}
