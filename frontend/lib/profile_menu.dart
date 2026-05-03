import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/logic/auth_service.dart';
import 'package:frontend/logic/http_requests.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/txt_styles.dart';
import 'package:provider/provider.dart';
import 'logic/user_info_provider.dart';

class ProfileMenu extends StatelessWidget {
  final VoidCallback onClose;

  const ProfileMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final String userEmail = context.read<UserInfoProvider>().email;
    final String userRole = context.read<UserInfoProvider>().passLevel == 0 ? "Администратор" : "Пользователь";

    return Column(
      children: [
        const SizedBox(height: 18),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(color: darkGreenC, shape: BoxShape.circle),
          child: Icon(Icons.person_2_rounded, color: milkC, size: 30),
        ),
        const SizedBox(height: 6),
        Text(userEmail, style: TxtStyles.bodyMedium.copyWith(color: darkGreenC)),
        Text(userRole, style: TxtStyles.bodySmall.copyWith(color: darkGreenC)),
        const SizedBox(height: 20),
        const Spacer(),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: InkWell(
            hoverColor: salatC,
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
                Icon(Icons.logout_rounded, color: darkGreenC, size: 30),
                const SizedBox(width: 8),
                Text("Выйти", style: TxtStyles.sidebarItem.copyWith(color: darkGreenC)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
