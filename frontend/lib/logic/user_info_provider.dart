import 'package:flutter/material.dart';

class UserInfoProvider extends ChangeNotifier {
  late int _id;
  late String _email;
  late int _passLVL;

  int get userId => _id;
  String get email => _email;
  int get passLevel => _passLVL;

  void setUserInfo({required int id, required String emailAddr, required int passLvl}) {
    _id = id;
    _email = emailAddr;
    _passLVL = passLvl;
  }
}