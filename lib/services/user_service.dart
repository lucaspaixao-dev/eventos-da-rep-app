import '../http/user_client.dart';

class UserService {
  final _userClient = UserClient();

  Future<void> goingToEvent(String userId, String eventId) async {
    await _userClient.going(userId, eventId);
  }

  Future<void> exitToEvent(String userId, String eventId) async {
    await _userClient.cancel(userId, eventId);
  }
}
