import 'package:flutter/material.dart';
import 'package:frontend/logic/auth_service.dart';
import 'package:frontend/logic/user_info_provider.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'logic/service.dart';

void main() {
  runApp(const OfficeApp());
}

class OfficeApp extends StatelessWidget {
  const OfficeApp({super.key});

  Future<bool> checkAuth(BuildContext context) async {
    final authService = AuthService();
    return await authService.isLoggedIn(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserInfoProvider())],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'Watch demo',
            theme: ThemeData(useMaterial3: true, fontFamily: "Inter"),
            home: FutureBuilder<bool>(
              future: checkAuth(context),
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
        },
      ),
    );
  }
}
