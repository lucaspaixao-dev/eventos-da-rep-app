class User {
  final String? id;
  final String name;
  final String authenticationId;
  final String email;
  final String photo;
  final List<String>? events;

  User({
    this.id,
    required this.name,
    required this.authenticationId,
    required this.email,
    required this.photo,
    this.events,
  });
}
