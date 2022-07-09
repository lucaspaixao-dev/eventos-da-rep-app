import 'dart:convert';

import 'package:eventos_da_rep/models/payment.dart';

import '../config/environment.dart';
import '../exceptions/exceptions.dart';
import '../services/firebase_service.dart';
import "package:http/http.dart" as http;

class PaymentClient {
  final String url = Environment().config!.apiHost;
  final FirebaseService _firebaseService = FirebaseService();

  Future<String> createPaymentIntent(String eventId, String userId) async {
    final token = await _firebaseService.getToken();

    final request = {
      'eventId': eventId,
      'userId': userId,
    };

    final response = await http.post(
      Uri.parse(
        "$url/payments",
      ),
      body: jsonEncode(request),
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

  Future<List<Payment>> getPaymentsByEventIdAndUserId(
    String eventId,
    String userId,
  ) async {
    final token = await _firebaseService.getToken();

    final response = await http.get(
      Uri.parse(
        "$url/payments?userId=$userId&eventId=$eventId",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Payment> payments =
          List<Payment>.from(json.map((e) => Payment.fromJson(e)));
      return payments;
    } else {
      throw ApiException(
        "Erro ao criar o pagamento, tente novamente mais tarde.",
      );
    }
  }
}
