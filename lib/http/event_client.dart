import 'dart:convert';
import 'package:eventos_da_rep/services/firebase_service.dart';
import "package:http/http.dart" as http;

import '../config/environment.dart';
import '../exceptions/exceptions.dart';
import '../helpers/internet_helper.dart';
import '../models/event.dart';

class EventClient {
  final String url = Environment().config!.apiHost;
  final FirebaseService _firebaseService = FirebaseService();

  Future<List<Event>> getEvents(int pageKey, int pageSize) async {
    final hasInternet = await checkInternetConnection();

    if (!hasInternet) {
      throw InternetException(
        "Sem conexão com a internet, por favor, verifique sua conexão e tente novamente.",
      );
    }

    try {
      final token = await _firebaseService.getToken();

      final response = await http.get(
        Uri.parse("$url/events/actives?page=$pageKey&size=$pageSize"),
        headers: {
          "Authorization": "Bearer $token",
        },
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

  Future<Event> getEventById(String eventId) async {
    final hasInternet = await checkInternetConnection();

    if (!hasInternet) {
      throw InternetException(
        "Sem conexão com a internet, por favor, verifique sua conexão e tente novamente.",
      );
    }

    try {
      final token = await _firebaseService.getToken();

      final response = await http.get(
        Uri.parse("$url/events/$eventId"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final dynamic json = jsonDecode(utf8.decode(response.bodyBytes));
        final Event event = Event.fromJson(json);
        return event;
      } else {
        throw ApiException(
          "Erro para buscar o evento, tente novamente mais tarde.",
        );
      }
    } catch (e) {
      throw ApiException(
        "Erro para buscar o evento, tente novamente mais tarde.",
      );
    }
  }
}
