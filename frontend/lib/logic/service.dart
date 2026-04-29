import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:web/web.dart' as web;

void navToPageClearly(BuildContext context, Widget page) {
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(pageBuilder: (_, _, _) => page, transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero),
    (_) => false,
  );
}

void logMsg(String msgType, String func, String data) {
  /*
  D - debug
  I - info
  W - warning
  E - error
  WTF - fatal error
   */
  final logger = Logger(level: kReleaseMode ? Level.off : Level.debug);
  String str = '[$func]: $data';
  switch (msgType) {
    case "D":
      logger.d(str);
      break;
    case "I":
      logger.i(str);
      break;
    case "W":
      logger.w(str);
      break;
    case "E":
      logger.e(str);
      break;
    case "WTF":
      logger.f(str);
      break;
    default:
      logger.d(str);
      break;
  }
}

String getBrowserName() {
  final ua = web.window.navigator.userAgent;

  if (ua.contains('YaBrowser') || ua.contains('Yowser')) {
    return 'Yandex Browser';
  }
  if (ua.contains('Edg/')) return 'Microsoft Edge';
  if (ua.contains('OPR/') || ua.contains('Opera')) return 'Opera';
  if (ua.contains('Chrome/')) return 'Chrome';
  if (ua.contains('Firefox/')) return 'Firefox';
  if (ua.contains('Safari/') && !ua.contains('Chrome')) return 'Safari';

  return 'Unknown Browser';
}

