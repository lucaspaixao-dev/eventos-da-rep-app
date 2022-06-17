import 'package:intl/intl.dart';

class Event {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final String city;
  final String address;
  final String description;
  final String photo;
  final DateTime date;
  final DateTime begin;
  final DateTime end;
  final bool active;
  final List<String> users;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.address,
    required this.description,
    required this.photo,
    required this.date,
    required this.begin,
    required this.end,
    required this.active,
    required this.createdAt,
    required this.users,
  });

  factory Event.fromJson(dynamic json) {
    List<String> _getUsersId(List<dynamic>? users) {
      List<String> currentUsers = [];

      if (users != null) {
        for (var user in users) {
          currentUsers.add(user['id']);
        }
      }

      return currentUsers;
    }

    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      city: json['city'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      photo: json['photo'] as String,
      date: DateTime.parse(json['date']),
      begin: DateFormat("HH:mm:ss").parse(json['begin']),
      end: DateFormat("HH:mm:ss").parse(json['end']),
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      users: _getUsersId(json['users']),
    );
  }
}
