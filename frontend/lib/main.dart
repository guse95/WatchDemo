import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';

void main() {
  runApp(const OfficeApp());
}

class OfficeApp extends StatelessWidget {
  const OfficeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watch demo',
      theme: ThemeData(useMaterial3: true, fontFamily: "ClusterAppFont"),
      home: LoginPage(),
    );
  }
}
