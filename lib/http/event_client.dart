import 'dart:convert';
import 'dart:io';
import "package:http/http.dart" as http;

import '../exceptions/exceptions.dart';
import '../models/event.dart';

class EventClient {
  late final String url;

  EventClient() {
    url = Platform.isAndroid
        ? "http://10.0.2.2:8080"
        : //"http://localhost:8080";
        "http://192.168.15.3:8080";
  }

  Future<List<Event>> getEvents(int pageKey, int pageSize) async {
    try {
      final response = await http.get(
        Uri.parse("$url/events/actives?page=$pageKey&size=$pageSize"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
        final List<Event> events =
            List<Event>.from(json.map((e) => Event.fromJson(e)));
        return events;
      } else {
        throw ApiException(
          "Erro para buscar os eventos, tente novamente mais tarde.",
        );
      }
    } catch (e) {
      throw ApiException(
        "Erro para buscar os eventos, tente novamente mais tarde.",
      );
    }
  }
}
