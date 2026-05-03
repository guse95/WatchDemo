import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/animated_menu.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/logic/user_info_provider.dart';
import 'package:frontend/pages/manage_resources_page.dart';
import 'package:frontend/pages/resource_list_page.dart';
import 'package:frontend/profile_menu.dart';
import 'package:frontend/txt_styles.dart';
import 'package:provider/provider.dart';

class TabInfo {
  int id;
  String name;
  String iconPath;

  TabInfo({required this.id, required this.name, required this.iconPath});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _profileButtonKey = GlobalKey();

  final List<TabInfo> _tabs = [
    TabInfo(id: 0, name: "Ресурсы", iconPath: "assets/icons/Board.svg"),
    TabInfo(id: 1, name: "Мои брони", iconPath: "assets/icons/BadgeCheck.svg"),
    TabInfo(id: 2, name: "Ресурсы", iconPath: "assets/icons/ResourcesEdit.svg"),
    TabInfo(id: 3, name: "Пользователи", iconPath: "assets/icons/Users.svg"),
  ];

  final List<Widget> _pages = [ResourceListPage(), SizedBox.shrink(), ManageResourcesPage(), SizedBox.shrink()];

  late int _tabsShown;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    final userPassLevel = context.read<UserInfoProvider>().passLevel;
    _tabsShown = userPassLevel == 0 ? 4 : 2;
  }

  @override
  Widget build(BuildContext context) {
    final String userEmail = context.read<UserInfoProvider>().email;
    final String userRole = context.read<UserInfoProvider>().passLevel == 0 ? "Администратор" : "Пользователь";

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
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: Container(width: double.infinity, height: 2, color: Color.fromRGBO(90, 130, 100, 1)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        ...List.generate(_tabsShown, (index) {
                          final tabItem = Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: _tabIndex == index ? salatC : Colors.transparent,
                              shape: IOSLikeShape(13),
                              clipBehavior: Clip.antiAlias,
                              child: SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  hoverColor: salatC.withValues(alpha: 0.4),
                                  onTap: () {
                                    logMsg("D", "Home page", "Tapped tab $index.");
                                    setState(() => _tabIndex = index);
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      SvgPicture.asset(
                                        _tabs[index].iconPath,
                                        width: 22,
                                        height: 22,
                                        colorFilter: ColorFilter.mode(_tabIndex == index ? darkGreenC : milkC, BlendMode.srcATop),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _tabs[index].name,
                                        style: _tabIndex == index
                                            ? TxtStyles.sidebarItemActive.copyWith(color: darkGreenC)
                                            : TxtStyles.sidebarItem.copyWith(color: milkC),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );

                          return Column(
                            children: [
                              tabItem,
                              if (index == 1)
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 40, 0, 16),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("АДМИНИСТРИРОВАНИЕ", style: TxtStyles.caption.copyWith(color: milkC, fontSize: 14)),
                                  ),
                                ),
                            ],
                          );
                        }),
                        const Spacer(),
                        Material(
                          key: _profileButtonKey,
                          shape: IOSLikeShape(25),
                          color: salatC,
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            height: 70,
                            child: InkWell(
                              onTap: () {
                                logMsg("D", "Home page", "Profile tapped.");
                                AnimatedMenu.show(
                                  context: context,
                                  anchorKey: _profileButtonKey,
                                  width: 260,
                                  height: 300,
                                  backgroundColor: milkC,
                                  preferredDirection: AnimatedMenuDirection.topCenter,
                                  shape: IOSLikeShape(30),
                                  builder: (context, close) {
                                    return ProfileMenu(onClose: close);
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(color: milkC, shape: BoxShape.circle),
                                    child: Icon(Icons.person_2_rounded, color: darkGreenC, size: 30),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(userEmail, style: TxtStyles.bodyMedium.copyWith(color: darkGreenC)),
                                      Text(userRole, style: TxtStyles.bodySmall.copyWith(color: darkGreenC)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(color: milkC, child: _pages[_tabIndex]),
          ),
        ],
      ),
    );
  }
}
