import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import "package:http/http.dart" as http;

import '../models/event.dart';

class EventClient {
  late final String url;

  EventClient() {
    url = Platform.isAndroid ? "http://10.0.2.2:8080" : "http://localhost:8080";
  }

  Future<List<Event>> getEvents(int pageKey, int pageSize) async {
    final response = await http.get(
      Uri.parse("$url/events"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Event> events =
          List<Event>.from(json.map((e) => Event.fromJson(e)));
      return events;
    } else {
      throw Exception('Failed to create a new user');
    }
  }
}
