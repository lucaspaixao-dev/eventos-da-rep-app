import 'package:eventos_da_rep/models/user.dart';
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
  final bool isPayed;
  final int? amount;
  final List<User> users;
  final DateTime createdAt;

  Event(
      {required this.id,
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
      required this.isPayed,
      this.amount});

  factory Event.fromJson(dynamic json) {
    List<User> _getUsersId(List<dynamic>? users) {
      List<User> currentUsers = [];

      if (users != null) {
        for (var user in users) {
          User u = User(
            id: user['id'] as String,
            name: user['name'] as String,
            email: user['email'] as String,
            photo: user['photo'] as String,
            events: null,
          );
          currentUsers.add(u);
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
      isPayed: json['isPayed'] as bool,
      amount: json['amount'] as int?,
    );
  }
}
