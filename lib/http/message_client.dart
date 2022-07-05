import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_message;

import '../config/environment.dart';
import '../exceptions/exceptions.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

import '../services/firebase_service.dart';

class MessageClient {
  final String url = Environment().config!.apiHost;
  final FirebaseService _firebaseService = FirebaseService();

  Stream<List<chat_message.Message>> getMessages(String eventId) async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));

      final token = await _firebaseService.getToken();

      try {
        final response = await http.get(
          Uri.parse(
            "$url/events/$eventId/messages",
          ),
          headers: {
            "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> json =
              jsonDecode(utf8.decode(response.bodyBytes));
          final List<chat_message.Message> messages =
              List<chat_message.Message>.from(
            json.map(
              (e) => chat_message.Message.fromJson(e),
            ),
          );
          yield messages;
        } else {
          throw ApiException(
            "Erro para buscar as mensagens, tente novamente mais tarde.",
          );
        }
      } catch (e) {
        throw ApiException(
          "Erro para buscar as mensagens, tente novamente mais tarde.",
        );
      }
    }
  }

  Future<void> sendMessage(String eventId, String userId, String text) async {
    var request = {
      'text': text,
    };

    final token = await _firebaseService.getToken();

    final response = await http.post(
      Uri.parse(
        "$url/events/$eventId/messages/user/$userId/send",
      ),
      body: jsonEncode(request),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 201) {
      throw ApiException(
        "Erro para enviar a mensagem, tente novamente mais tarde.",
      );
    }
  }
}
