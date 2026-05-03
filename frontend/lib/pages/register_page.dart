import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/cls_textfield.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/logic/auth_service.dart';
import 'package:frontend/logic/http_requests.dart';
import 'package:frontend/logic/user_info_provider.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/txt_styles.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _pass1TextController = TextEditingController();
  final TextEditingController _pass2TextController = TextEditingController();
  String? _emailTextError;
  String? _passError;

  Future<void> register() async {
    if (_emailTextController.text.isEmpty) {
      setState(() => _emailTextError = "Укажите e-mail");
      return;
    }
    if (_pass1TextController.text.isEmpty) {
      setState(() => _passError = "Придумайте пароль");
      return;
    }
    if (_pass1TextController.text != _pass2TextController.text) {
      setState(() => _passError = "Пароли не совпадают");
      return;
    }

    final userAgent = getBrowserName();
    logMsg("D", "Register", "Got user agent - $userAgent.");

    final r = await HttpRequests().sendRegisterRequest(
      email: _emailTextController.text,
      password: _pass1TextController.text,
      agent: userAgent,
    );
    final body = jsonDecode(r.body);
    if (r.statusCode == 200) {
      final accessToken = body["access_token"];
      final refreshToken = body["refresh_token"];
      await AuthService().saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      logMsg("D", "Register", "Tokens saved.");

      if (!mounted) return;
      final payload = parseJwtPayload(accessToken);
      int id = int.parse(payload["sub"]);
      String email = payload["email"];
      int passLvl = payload["pass_lvl"];
      logMsg("D", "Login", "Payload: $payload\nID - $id\nEmail - $email\nPass level - $passLvl");
      context.read<UserInfoProvider>().setUserInfo(id: id, emailAddr: email, passLvl: passLvl);
      navToPageClearly(context, HomePage());
      return;
    }
    if (r.statusCode == 400) {
      final detail = body["detail"];
      if (detail == "Email already registered") {
        setState(() => _emailTextError = "Этот e-mail уже зарегистрирован");
        return;
      }
    }
    if (r.statusCode == 422) {
      setState(() => _emailTextError = "Некорректный e-mail");
      return;
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
                            "Регистрация",
                            style: TxtStyles.h1.copyWith(color: milkC)
                          ),
                          const SizedBox(height: 32),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Введите почту",
                                style: TxtStyles.body.copyWith(color: milkC)
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClsTextfield(
                            controller: _emailTextController,
                            hint: "e-mail",
                            errorText: _emailTextError,
                            onChanged: (_) {
                              setState(() => _emailTextError = null);
                            },
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Придумайте пароль",
                                style: TxtStyles.body.copyWith(color: milkC)
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClsTextfield(
                            controller: _pass1TextController,
                            hint: "Пароль",
                            hide: true,
                            errorText: _passError,
                            onChanged: (_) {
                              setState(() => _passError = null);
                            },
                          ),
                          const SizedBox(height: 8),
                          ClsTextfield(
                            controller: _pass2TextController,
                            hint: "Подтверждение пароля",
                            hide: true,
                            errorText: _passError,
                            onChanged: (_) {
                              setState(() => _passError = null);
                            },
                          ),
                          const SizedBox(height: 32),
                          Material(
                            color: accentGreenC,
                            shape: IOSLikeShape(27),
                            clipBehavior: Clip.antiAlias,
                            elevation: 7,
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: InkWell(
                                onTap: () async {
                                  logMsg("D", "Register page", "Tapped - register.");
                                  await register();
                                },
                                child: Center(
                                  child: Text(
                                    "Зарегистрироваться",
                                    style: TxtStyles.buttonLarge.copyWith(color: milkC),
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
                                "Уже есть аккаунт? ",
                                  style: TxtStyles.bodyMedium.copyWith(color: milkC),
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
                                  logMsg("D", "Register page", "Tapped - go to login.");
                                  navToPageClearly(context, LoginPage());
                                },
                                child: Text(
                                  "Войти",
                                  style: TxtStyles.bodyMedium.copyWith(
                                    color: milkC,
                                    decoration: TextDecoration.underline,
                                    decorationColor: milkC,
                                    decorationThickness: 1,
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
