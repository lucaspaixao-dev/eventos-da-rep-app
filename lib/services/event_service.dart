import 'package:eventos_da_rep/http/event_client.dart';
import 'package:eventos_da_rep/models/payment.dart';

import '../models/event.dart';
import '../models/user.dart';
import 'payment_service.dart';

class EventService {
  final _eventClient = EventClient();
  final _paymentService = PaymentService();

  Future<Event> getEventById(String eventId) async {
    try {
      return await _eventClient.getEventById(eventId);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkIfUserIsGoingToEvent(
    String? userId,
    Event event,
  ) async {
    if (userId == null) {
      return false;
    }

    if (event.isPayed) {
      return _checkUserPaidForTheEvent(userId, event.id);
    }

    List<User> users = event.users;
    if (users.isEmpty) {
      return false;
    }

    return _checkUserOnList(userId, users);
  }

  Future<bool> _checkUserPaidForTheEvent(String userId, String eventId) async {
    List<Payment> payments =
        await _paymentService.getPaymentsByUserIdAndEventId(
      userId,
      eventId,
    );

    for (Payment p in payments) {
      if (p.status == PaymentStatus.success) {
        return true;
      }
    }

    return false;
  }

  bool _checkUserOnList(String userId, List<User> users) {
    for (var user in users) {
      if (user.id == userId) {
        return true;
      }
    }

    return false;
  }
}
