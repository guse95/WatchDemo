import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/animated_menu.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/profile_menu.dart';
import 'package:frontend/txt_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _profileButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(40, 40, 40, 1),
      body: Row(
        children: [
          Container(
            width: 300,
            height: double.infinity,
            color: darkGreenC,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 0, 32),
                  child: Row(
                    children: [
                      Image.asset("assets/images/logo2.png", height: 40),
                      const SizedBox(width: 12),
                      Text("Reservo", style: TxtStyles.h2.copyWith(color: milkC)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                  child: Container(width: double.infinity, height: 2, color: Color.fromRGBO(90, 130, 100, 1)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: milkC,
            ),
          )
        ],
      ),
    );
  }
}
