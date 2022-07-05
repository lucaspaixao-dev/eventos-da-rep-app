import 'dart:convert';

import '../config/environment.dart';
import '../exceptions/exceptions.dart';
import '../services/firebase_service.dart';
import "package:http/http.dart" as http;

class PaymentClient {
  final String url = Environment().config!.apiHost;
  final FirebaseService _firebaseService = FirebaseService();

  Future<String> createPaymentIntent(String eventId, String userId) async {
    final token = await _firebaseService.getToken();

    final response = await http.post(
      Uri.parse(
        "$url/events/$eventId/users/$userId/payments",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['id'];
    } else {
      throw ApiException(
        "Erro ao criar o pagamento, tente novamente mais tarde.",
      );
    }
  }
}
