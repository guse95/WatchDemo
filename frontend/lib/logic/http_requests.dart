import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/logic/auth_service.dart';
import 'package:frontend/logic/resource_model.dart';
import 'package:frontend/logic/service.dart';
import 'package:http/http.dart' as http;

enum LoginStaus { success, wrongPass, noSuchEmail }

class HttpRequests {
  static final HttpRequests _instance = HttpRequests._internal();

  factory HttpRequests() => _instance;

  HttpRequests._internal();

  String apiUrl = kDebugMode ? "http://localhost:8002" : "/api";

  Future<http.Response> sendWhoisRequest({required String refToken}) async {
    final accessToken = await AuthService().getAccessToken();
    if (accessToken == null) {
      throw Exception("Access token is null");
    }
    final payload = parseJwtPayload(accessToken);
    logMsg("D", "Send whois request", "Access token: $accessToken\nPayload: $payload");
    final response = await http.get(
      Uri.parse("$apiUrl/auth/whois").replace(queryParameters: {"ref_token": refToken}),
      headers: {"Authorization": "Bearer $accessToken"},
    );
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
    final accessToken = await AuthService().getAccessToken();
    final response = await http.post(
      Uri.parse("$apiUrl/auth/logout").replace(queryParameters: {"token": refToken}),
      headers: {"Authorization": "Bearer $accessToken", "Content-Type": "application/json"},
    );
    logMsg("D", "Register request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }

  Future<List<Resource>> fetchResources({required int page, required int limit, String? type}) async {
    final accessToken = await AuthService().getAccessToken();
    http.Response response;

    if (type == null) {
      response = await http.get(
        Uri.parse(
          "$apiUrl/resources/user/all",
        ).replace(queryParameters: {"start_ind": (page * limit).toString(), "limit": (limit).toString()}),
        headers: {"Authorization": "Bearer $accessToken"},
      );
    } else {
      response = await http.get(
        Uri.parse(
          "$apiUrl/resources/user/$type",
        ).replace(queryParameters: {"start_ind": (page * limit).toString(), "limit": (limit).toString()}),
        headers: {"Authorization": "Bearer $accessToken"},
      );
    }

    final body = jsonDecode(response.body);
    logMsg("D", "Fetch resources", "Fetched ${body.length} resources.");
    return List.generate(body.length, (index) {
      final data = body[index];
      final res = Resource.fromJson(data);
      return res;
    });
  }

  Future<http.Response> sendAddResourceRequest({required Map<String, dynamic> params}) async {
    final accessToken = await AuthService().getAccessToken();
    final reqBody = jsonEncode(params);
    logMsg("D", "Send add resource request", reqBody);
    final response = await http.post(
      Uri.parse("$apiUrl/resources/admin/create"),
      headers: {"Authorization": "Bearer $accessToken", "Content-Type": "application/json"},
      body: reqBody,
    );
    logMsg("D", "Register request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }

  Future<http.Response> sendUpdateResourceRequest({required Map<String, dynamic> params}) async {
    final accessToken = await AuthService().getAccessToken();
    final reqBody = jsonEncode(params);
    logMsg("D", "Send add resource request", reqBody);
    final response = await http.put(
      Uri.parse("$apiUrl/resources/admin/update"),
      headers: {"Authorization": "Bearer $accessToken", "Content-Type": "application/json"},
      body: reqBody,
    );
    logMsg("D", "Register request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }

  Future<http.Response> sendDeleteResourceRequest({required int id}) async {
    final accessToken = await AuthService().getAccessToken();
    final response = await http.delete(
      Uri.parse("$apiUrl/resources/admin/delete/$id"),
      headers: {"Authorization": "Bearer $accessToken"},
    );
    logMsg("D", "Register request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }
}
