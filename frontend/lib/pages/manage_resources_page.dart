import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/add_resource_menu.dart';
import 'package:frontend/elements/animated_menu.dart';
import 'package:frontend/elements/cls_checkbox.dart';
import 'package:frontend/elements/cls_textfield.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/elements/param_textfield.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/txt_styles.dart';

class ResourceRow extends StatelessWidget {
  const ResourceRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Material(
            shape: IOSLikeShape(10),
            clipBehavior: Clip.antiAlias,
            child: Container(
              height: 54,
              width: 80,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/images/back.jpg"), fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 260,
            child: Text("Переговорная альфа", style: TxtStyles.bodyMedium.copyWith(color: blackC)),
          ),
          Text("Комната", style: TxtStyles.body.copyWith(color: lightBlackC)),
          const Spacer(),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 40,
              height: 40,
              child: InkWell(
                onTap: () {
                  logMsg("D", "Manage resources", "Tapped edit.");
                },
                child: Icon(Icons.edit_rounded, color: lightBlackC, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 40,
              height: 40,
              child: InkWell(
                onTap: () {
                  logMsg("D", "Manage resources", "Tapped delete.");
                },
                child: Icon(Icons.delete_outline, color: Colors.red, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }
}

class ManageResourcesPage extends StatefulWidget {
  const ManageResourcesPage({super.key});

  @override
  State<ManageResourcesPage> createState() => _ManageResourcesPageState();
}

class _ManageResourcesPageState extends State<ManageResourcesPage> with SingleTickerProviderStateMixin {
  final GlobalKey _addResourceButtonKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController;
  int selectedIndex = 0;

  final List<String> _tabNames = ["Все", "Комнаты", "Ноутбуки", "Доски", "Проекторы"];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabNames.length, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index != selectedIndex) {
        setState(() {
          selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Управление ресурсами", style: TxtStyles.h1.copyWith(color: blackC)),
          const SizedBox(height: 18),
          Row(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,

                labelPadding: const EdgeInsets.only(right: 24),
                padding: EdgeInsets.zero,

                labelColor: accentGreenC,
                unselectedLabelColor: blackC,
                labelStyle: TxtStyles.sidebarItemActive.copyWith(color: accentGreenC),
                unselectedLabelStyle: TxtStyles.sidebarItem.copyWith(color: accentGreenC),

                indicatorColor: darkGreenC,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,

                dividerColor: Colors.transparent,
                tabs: List.generate(_tabNames.length, (index) {
                  return Tab(text: _tabNames[index]);
                }),
              ),
              const Spacer(),
              Material(
                key: _addResourceButtonKey,
                color: accentGreenC,
                shape: IOSLikeShape(14),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 45,
                  child: InkWell(
                    onTap: () {
                      logMsg("D", "Manage resources", "Tapped - add resource.");
                      AnimatedMenu.show(
                        context: context,
                        anchorKey: _addResourceButtonKey,
                        width: 600,
                        height: 535,
                        backgroundColor: milkC,
                        preferredDirection: AnimatedMenuDirection.bottomRight,
                        shape: IOSLikeShape(30),
                        builder: (context, close) {
                          return AddResourceMenu(onClose: close);
                        },
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 10),
                        Icon(Icons.add, color: milkC, size: 25),
                        const SizedBox(width: 4),
                        Text(
                          "Добавить ресурс",
                          style: TxtStyles.bodyMedium.copyWith(color: milkC, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipPath(
              clipper: IOSLikeClipper(20),
              child: Material(
                color: milkC,
                shape: IOSLikeShape(20, side: BorderSide(width: 2, color: darkMilkC)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                      child: Row(
                        children: [
                          Text(
                            "Фото",
                            style: TxtStyles.bodyMedium.copyWith(color: blackC, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 57),
                          Text(
                            "Название",
                            style: TxtStyles.bodyMedium.copyWith(color: blackC, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 180),
                          Text(
                            "Тип",
                            style: TxtStyles.bodyMedium.copyWith(color: blackC, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(
                            "Действия",
                            style: TxtStyles.bodyMedium.copyWith(color: blackC, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(accentGreenC),
                          thickness: WidgetStateProperty.all(10),
                          radius: const Radius.circular(8),
                        ),
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller: _scrollController,
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return ResourceRow();
                            },
                            separatorBuilder: (context, index) {
                              return Divider(height: 1, thickness: 1, color: darkMilkC);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
