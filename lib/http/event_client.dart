import 'dart:convert';
import "package:http/http.dart" as http;

import '../config/environment.dart';
import '../exceptions/exceptions.dart';
import '../helpers/internet_helper.dart';
import '../models/event.dart';

class EventClient {
  final String url = Environment().config!.apiHost;

  Future<List<Event>> getEvents(int pageKey, int pageSize) async {
    final hasInternet = await checkInternetConnection();

    if (!hasInternet) {
      throw InternetException(
        "Sem conexão com a internet, por favor, verifique sua conexão e tente novamente.",
      );
    }

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
