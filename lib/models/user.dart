import 'package:eventos_da_rep/models/device.dart';

class User {
  final String? id;
  final String name;
  final String authenticationId;
  final String email;
  final String photo;
  final Device device;
  final List<String>? events;

  User({
    this.id,
    required this.name,
    required this.authenticationId,
    required this.email,
    required this.photo,
    required this.device,
    this.events,
  });
}
