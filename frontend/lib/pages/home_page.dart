import 'package:flutter/material.dart';
import 'package:frontend/elements/animated_menu.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/profile_menu.dart';

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Image.asset("assets/images/logo_big.png", height: 70),
                const Spacer(),
                SizedBox(
                  width: 65,
                  height: 65,
                  child: GestureDetector(
                    onTap: () {
                      AnimatedMenu.show(
                        context: context,
                        anchorKey: _profileButtonKey,
                        width: 250,
                        height: 400,
                        backgroundColor: Color.fromRGBO(20, 20, 20, 1),
                        preferredDirection: AnimatedMenuDirection.auto,
                        shape: IOSLikeShape(30),
                        builder: (context, close) {
                          return ProfileMenu(onClose: close);
                        },
                      );
                    },
                    child: Container(
                      key: _profileButtonKey,
                      decoration: BoxDecoration(color: Colors.lightBlue, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
