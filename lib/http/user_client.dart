import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:eventos_da_rep/models/device.dart';
import "package:http/http.dart" as http;

import '../models/user.dart';

class UserClient {
  late final String url;

  UserClient() {
    url = Platform.isAndroid ? "http://10.0.2.2:8080" : "http://localhost:8080";
  }

  Future<String> createUser(User user) async {
    var request = {
      'name': user.name,
      'email': user.email,
      'authenticationId': user.authenticationId,
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
      throw Exception('Failed to create a new user');
    }
  }

  Future<void> syncDevide(String userId, Device device) async {
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
      throw Exception('Failed to sync the device');
    }
  }

  Future<void> going(String userId, String eventId) async {
    final response =
        await http.put(Uri.parse("$url/users/$userId/events/$eventId/join"));

    if (response.statusCode != 204) {
      throw Exception('Failed to join event');
    }
  }

  Future<void> cancel(String userId, String eventId) async {
    final response =
        await http.put(Uri.parse("$url/users/$userId/events/$eventId/cancel"));

    if (response.statusCode != 204) {
      throw Exception('Failed to join event');
    }
  }
}
