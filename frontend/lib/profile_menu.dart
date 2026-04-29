import 'package:flutter/material.dart';
import 'package:frontend/logic/auth_service.dart';
import 'package:frontend/logic/http_requests.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/pages/login_page.dart';

class ProfileMenu extends StatelessWidget {
  final VoidCallback onClose;

  const ProfileMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: Colors.lightBlue, shape: BoxShape.circle),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: InkWell(
            hoverColor: Color.fromRGBO(70, 70, 70, 1),
            onTap: () async {
              logMsg("D", "Profile menu", "Sign out tapped.");
              final refToken = await AuthService().getRefreshToken();
              if (refToken == null) {
                onClose();
                await AuthService().removeTokens();
                navToPageClearly(context, LoginPage());
                logMsg("E", "Logout", "Ref token is NULL. Logging out");
                return;
              }
              final r = await HttpRequests().sendLogoutRequest(refToken: refToken);
              if (r.statusCode == 400) {
                onClose();
                await AuthService().removeTokens();
                navToPageClearly(context, LoginPage());
                logMsg("E", "Logout", "Logging out");
                return;
              }
              if (r.statusCode == 200) {
                onClose();
                await AuthService().removeTokens();
                navToPageClearly(context, LoginPage());
                logMsg("D", "Logout", "Successfully logged out");
                return;
              }
            },
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.logout_rounded, color: Colors.white, size: 30),
                const SizedBox(width: 8),
                Text(
                  "Выйти",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
