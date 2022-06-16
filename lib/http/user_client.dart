import 'dart:convert';
import 'dart:io';
import 'package:eventos_da_rep/exceptions/exceptions.dart';
import 'package:eventos_da_rep/models/device.dart';
import "package:http/http.dart" as http;

import '../models/user.dart';

class UserClient {
  late final String url;

  UserClient() {
    url = Platform.isAndroid
        ? "http://10.0.2.2:8080"
        : //"http://localhost:8080";
        "http://192.168.15.3:8080";
  }

  Future<String> createUser(User user) async {
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

      final response = await http.post(
        Uri.parse("$url/users"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(request),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['id'];
      } else {
        throw ApiException(
          "Erro para criar um novo usuário, tente novamente mais tarde.",
        );
      }
    } catch (e) {
      throw ApiException(
        "Erro para criar um novo usuário, tente novamente mais tarde.",
      );
    }
  }

  Future<void> syncDevide(String userId, Device device) async {
    try {
      var request = {
        'brand': device.brand,
        'model': device.model,
        'token': device.token,
      };

      final response = await http.put(
        Uri.parse("$url/users/$userId/devices"),
        headers: <String, String>{
          'Content-Type': 'application/json',
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
    try {
      final response = await http.get(
        Uri.parse("$url/users/email/$email"),
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
    try {
      final response = await http
          .put(Uri.parse("$url/events/$eventId/users/$userId/accept"));

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
    try {
      final response = await http
          .put(Uri.parse("$url/events/$eventId/users/$userId/disavow"));

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
