import 'package:eventos_da_rep/models/device.dart';

class User {
  final String? id;
  final String name;
  final String email;
  final String photo;
  final Device? device;
  final List<String>? events;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.photo,
    this.device,
    this.events,
  });

  factory User.fromJson(dynamic json) {
    List<String> _getEventsId(List<dynamic>? eventsId) {
      if (eventsId == null) {
        return [];
      }
      return eventsId.cast<String>().toList();
    }

    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photo: json['photo'] as String,
      events: _getEventsId(json['events']),
      device: json['device'] != null ? Device.fromJson(json['device']) : null,
    );
  }
}
