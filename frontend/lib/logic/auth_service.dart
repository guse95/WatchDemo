import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/logic/http_requests.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/logic/user_info_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class AuthService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> removeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    logMsg("D", "Auth service", "Tokens removed.");
  }

  Future<bool> isLoggedIn(BuildContext context) async {
    try {
      final refToken = await getRefreshToken();
      if (refToken == null || refToken.isEmpty) {
        logMsg("D", "Is logged in", "No saved token. User is not logged id.");
        return false;
      }
      logMsg("D", "Is logged in", "Found token: $refToken");

      final response = await HttpRequests().sendWhoisRequest(refToken: refToken);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        logMsg("D", "Is logged in", "User is logged in.");
        context.read<UserInfoProvider>().setUserInfo(id: data["id"], emailAddr: data["email"], passLvl: data["pass_level"]);
        return true;
      } else {
        await removeTokens();
        logMsg("E", "Is logged in", "User is not logged in. Tokens deleted.");
        return false;
      }
    } catch (e) {
      logMsg("E", "Is logged in", e.toString());
      return false;
    }
  }
}
