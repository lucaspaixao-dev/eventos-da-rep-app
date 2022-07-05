import 'dart:convert';
import 'package:eventos_da_rep/config/environment.dart';
import 'package:eventos_da_rep/exceptions/exceptions.dart';
import 'package:eventos_da_rep/models/device.dart';
import "package:http/http.dart" as http;

import '../helpers/internet_helper.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

class UserClient {
  final String url = Environment().config!.apiHost;
  final FirebaseService _firebaseService = FirebaseService();

  Future<String> createUser(User user) async {
    final hasInternet = await checkInternetConnection();

    if (!hasInternet) {
      throw InternetException(
        "Sem conexão com a internet, por favor, verifique sua conexão e tente novamente.",
      );
    }

    try {
      var request = {
        'name': user.name,
        'email': user.email,
        'photo': user.photo,
        'isAdmin': false,
        'device': {
          'brand': user.device.brand,
          'model': user.device.model,
          'token': user.device.token,
        },
      };
      final token = await _firebaseService.getToken();

      final response = await http.post(
        Uri.parse("$url/users"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['id'];
      }
      if (response.statusCode == 403) {
        throw ApiException(
          "Você não possuí um convite para acessar o app, por favor entre em contato com a admistração.",
        );
      } else {
        throw ApiException(
          "Erro para criar um novo usuário, tente novamente mais tarde.",
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        "Erro para criar um novo usuário, tente novamente mais tarde.",
      );
    }
  }

  Future<void> syncDevide(String userId, Device device) async {
    final hasInternet = await checkInternetConnection();

    if (!hasInternet) {
      throw InternetException(
        "Sem conexão com a internet, por favor, verifique sua conexão e tente novamente.",
      );
    }

    try {
      var request = {
        'brand': device.brand,
        'model': device.model,
        'token': device.token,
      };

      final token = await _firebaseService.getToken();
      final response = await http.put(
        Uri.parse("$url/users/$userId/devices"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request),
      );

      if (response.statusCode != 204) {
        throw ApiException(
            'Erro para sincronizar o dispositivo, tente novamente mais tarde.');
      }
    } catch (e) {
      throw ApiException(
        "Erro para sincronizar o dispositivo, tente novamente mais tarde.",
      );
    }
  }

  Future<User> findByEmail(String email) async {
    final hasInternet = await checkInternetConnection();

    if (!hasInternet) {
      throw InternetException(
        "Sem conexão com a internet, por favor, verifique sua conexão e tente novamente.",
      );
    }

    final token = await _firebaseService.getToken();

    try {
      final response = await http.get(
        Uri.parse("$url/users/email/$email"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return User.fromJson(json);
      } else {
        throw ApiException(
          "Erro para buscar o usuário, tente novamente mais tarde.",
        );
      }
    } catch (e) {
      throw ApiException(
        "Erro para buscar o usuário, tente novamente mais tarde.",
      );
    }
  }

  Future<void> going(String userId, String eventId) async {
    final hasInternet = await checkInternetConnection();

    if (!hasInternet) {
      throw InternetException(
        "Sem conexão com a internet, por favor, verifique sua conexão e tente novamente.",
      );
    }

    final token = await _firebaseService.getToken();

    try {
      final response = await http.put(
        Uri.parse("$url/events/$eventId/users/$userId/accept"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw ApiException(
            "Erro para confirmar presença, tente novamente mais tarde.");
      }
    } catch (e) {
      throw ApiException(
        "Erro para confirmar presença, tente novamente mais tarde.",
      );
    }
  }

  Future<void> cancel(String userId, String eventId) async {
    final hasInternet = await checkInternetConnection();

    if (!hasInternet) {
      throw InternetException(
        "Sem conexão com a internet, por favor, verifique sua conexão e tente novamente.",
      );
    }

    final token = await _firebaseService.getToken();

    try {
      final response = await http.put(
        Uri.parse("$url/events/$eventId/users/$userId/disavow"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 204) {
        throw ApiException(
            "Erro para confirmar presença, tente novamente mais tarde.");
      }
    } catch (e) {
      throw ApiException(
        "Erro para cancelar presença, tente novamente mais tarde.",
      );
    }
  }
}
