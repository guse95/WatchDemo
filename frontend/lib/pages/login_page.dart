import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/elements/cls_textfield.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/logic/auth_service.dart';
import 'package:frontend/logic/http_requests.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/register_page.dart';
import 'package:frontend/logic/service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailTextController = TextEditingController();
  String? _emailErrorText;
  final TextEditingController _passTextController = TextEditingController();
  String? _passErrorText;

  Future<void> login() async {
    if (_emailTextController.text.isEmpty) {
      setState(() => _emailErrorText = "Укажите e-mail");
      return;
    }
    if (!_emailTextController.text.contains("@")) {
      setState(() => _emailErrorText = "Некорректный e-mail");
      return;
    }
    if (_passTextController.text.isEmpty) {
      setState(() => _passErrorText = "Введите пароль");
      return;
    }

    final userAgent = getBrowserName();
    logMsg("D", "Login", "Got user agent - $userAgent.");

    final r = await HttpRequests().sendLoginRequest(email: _emailTextController.text, password: _passTextController.text, agent: userAgent);
    final body = jsonDecode(r.body);
    if (r.statusCode == 200) {
      final accessToken = body["access_token"];
      final refreshToken = body["refresh_token"];
      await AuthService().saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      logMsg("D", "Login", "Tokens saved.");
      if (!mounted) return;
      navToPageClearly(context, HomePage());
      return;
    }
    if (r.statusCode == 400) {
      final detail = body["detail"];
      if (detail == "No user with this email") {
        setState(() => _emailErrorText = "Этот e-mail не зарегистрирован");
        return;
      } else if (detail == "Invalid password") {
        setState(() => _passErrorText = "Неверный пароль");
        return;
      }
    }
    if (r.statusCode == 422) {
      final msg = body['detail'][0]['msg'];
      if (msg.contains("not a valid email")) {
        setState(() => _emailErrorText = "Некорректный e-mail");
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double formWidth = 400;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/back.jpg"), fit: BoxFit.cover),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: formWidth),
            child: ClipPath(
              clipper: IOSLikeClipper(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: IOSLikeShape(50, side: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 2)),
                  child: SizedBox(
                    width: formWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 32),
                          Text(
                            "Добро пожаловать!",
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(height: 0),
                          Text(
                            "Войдите, чтобы продолжить",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                          const SizedBox(height: 32),
                          ClsTextfield(
                            controller: _emailTextController,
                            hint: "e-mail",
                            errorText: _emailErrorText,
                            onChanged: (_) {
                              setState(() => _emailErrorText = null);
                            },
                          ),
                          const SizedBox(height: 12),
                          ClsTextfield(
                            controller: _passTextController,
                            hint: "Пароль",
                            hide: true,
                            errorText: _passErrorText,
                            onChanged: (_) {
                              setState(() => _passErrorText = null);
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 6, 6, 0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: Colors.transparent,
                                ),
                                onPressed: () {
                                  logMsg("D", "Login page", "Tapped - forgot password.");
                                },
                                child: Text(
                                  "Забыли пароль?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                    decorationThickness: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Material(
                            color: Colors.deepPurple,
                            shape: IOSLikeShape(27),
                            clipBehavior: Clip.antiAlias,
                            elevation: 7,
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: InkWell(
                                onTap: () async {
                                  logMsg("D", "Login page", "Tapped - login.");
                                  await login();
                                },
                                child: Center(
                                  child: Text(
                                    "Войти",
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Нет аккаунта? ",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  splashFactory: NoSplash.splashFactory,
                                  overlayColor: Colors.transparent,
                                ),
                                onPressed: () {
                                  logMsg("D", "Login page", "Tapped - go to register.");
                                  navToPageClearly(context, RegisterPage());
                                },
                                child: Text(
                                  "Зарегистрироваться",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                    decorationThickness: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
