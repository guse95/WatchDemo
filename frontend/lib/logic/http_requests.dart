import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/logic/service.dart';
import 'package:http/http.dart' as http;

enum LoginStaus { success, wrongPass, noSuchEmail }

class HttpRequests {
  static final HttpRequests _instance = HttpRequests._internal();

  factory HttpRequests() => _instance;

  HttpRequests._internal();

  String apiUrl = kDebugMode ? "http://localhost:8002" : "/api";

  Future<http.Response> sendWhoisRequest({required String refToken}) async {
    final response = await http.get(Uri.parse("$apiUrl/auth/whois").replace(queryParameters: {"ref_token": refToken}));
    logMsg("D", "Login request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }

  Future<http.Response> sendLoginRequest({required String email, required String password, required String agent}) async {
    final response = await http.post(
      Uri.parse("$apiUrl/auth/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password, "user_agent": agent}),
    );
    logMsg("D", "Login request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }

  Future<http.Response> sendRegisterRequest({required String email, required String password, required String agent}) async {
    final response = await http.post(
      Uri.parse("$apiUrl/auth/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password, "username": null, "user_agent": agent}),
    );
    logMsg("D", "Register request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }

  Future<http.Response> sendLogoutRequest({required String refToken}) async {
    final response = await http.post(Uri.parse("$apiUrl/auth/logout").replace(queryParameters: {"token": refToken}));
    logMsg("D", "Register request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }
}
