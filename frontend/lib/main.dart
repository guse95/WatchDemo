import 'package:flutter/material.dart';
import 'package:frontend/logic/auth_service.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/login_page.dart';

import 'logic/service.dart';

void main() {
  runApp(const OfficeApp());
}

class OfficeApp extends StatelessWidget {
  const OfficeApp({super.key});

  Future<bool> checkAuth() async {
    final authService = AuthService();
    return await authService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watch demo',
      theme: ThemeData(useMaterial3: true, fontFamily: "ClusterAppFont"),
      home: FutureBuilder<bool>(
        future: checkAuth(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasError) {
            logMsg("E", "Auth check", snapshot.error.toString());
            return const LoginPage();
          }

          if (snapshot.data == true) {
            return const HomePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
