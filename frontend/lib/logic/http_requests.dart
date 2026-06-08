import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/logic/auth_service.dart';
import 'package:frontend/logic/booking_model.dart';
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
    logMsg("D", "Whois request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
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
    logMsg("D", "Logout request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
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
    logMsg("D", "Add res request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
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
    logMsg("D", "Update res request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }

  Future<http.Response> sendDeleteResourceRequest({required int id}) async {
    final accessToken = await AuthService().getAccessToken();
    final response = await http.delete(Uri.parse("$apiUrl/resources/admin/delete/$id"), headers: {"Authorization": "Bearer $accessToken"});
    logMsg("D", "Delete res request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }

  String dateTimeToApiString(DateTime dateTime) {
    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$year-$month-${day}T$hour:$minute';
  }

  Future<List<Booking>> fetchBookingsForResource({required int id, required DateTime day}) async {
    final accessToken = await AuthService().getAccessToken();

    final startTime = dateTimeToApiString(day);
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59);
    final endTime = dateTimeToApiString(endOfDay);

    final response = await http.get(
      Uri.parse("$apiUrl/resources/user/book/$id").replace(queryParameters: {"time_from": startTime, "time_to": endTime}),
      headers: {"Authorization": "Bearer $accessToken"},
    );
    logMsg("D", "Fetch bookings request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");

    List<Booking> bookings = [];
    final data = jsonDecode(response.body);
    for (var booking in data) {
      final bookingObj = Booking.fromJson(booking);
      bookings.add(bookingObj);
    }
    return bookings;
  }

  Future<http.Response> bookResourceRequest({required int id, required String desc, required String from, required String to}) async {
    final accessToken = await AuthService().getAccessToken();

    final response = await http.post(
      Uri.parse("$apiUrl/resources/user/book/$id").replace(queryParameters: {"description": desc, "booked_from": from, "booked_to": to}),
      headers: {"Authorization": "Bearer $accessToken"},
    );
    logMsg("D", "Book res request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }

  Future<List<Booking>> fetchMyBookings() async {
    final accessToken = await AuthService().getAccessToken();

    final now = DateTime.now();
    final nowPlus30 = now.add(const Duration(days: 30));
    String from = dateTimeToApiString(now);
    String to = dateTimeToApiString(nowPlus30);

    final response = await http.get(
      Uri.parse("$apiUrl/resources/user/book/my").replace(queryParameters: {"time_from": from, "time_to": to}),
      headers: {"Authorization": "Bearer $accessToken"},
    );
    final data = jsonDecode(response.body);
    logMsg("D", "Fetch my bookings", "Code ${response.statusCode}. Body:\n$data");

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch bookings: ${response.statusCode}");
    }
    if (data is! List) {
      throw const FormatException("Bookings response must be a list");
    }

    final bookings = data.map((booking) => Booking.fromJson(Map<String, dynamic>.from(booking as Map))).toList()
      ..sort((first, second) => first.bookedFrom.compareTo(second.bookedFrom));
    return bookings;
  }

  Future<http.Response> cancelBookingRequest({required int id}) async {
    final accessToken = await AuthService().getAccessToken();
    final response = await http.patch(Uri.parse("$apiUrl/resources/user/book/$id"), headers: {"Authorization": "Bearer $accessToken"});
    logMsg("D", "Cancel book request", "Code ${response.statusCode}. Body:\n${jsonDecode(response.body)}");
    return response;
  }
}
