import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/txt_styles.dart';

class ManageResourcesPage extends StatefulWidget {
  const ManageResourcesPage({super.key});

  @override
  State<ManageResourcesPage> createState() => _ManageResourcesPageState();
}

class _ManageResourcesPageState extends State<ManageResourcesPage> with SingleTickerProviderStateMixin {
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
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
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
                color: accentGreenC,
                shape: IOSLikeShape(14),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 45,
                  child: InkWell(
                    onTap: () {
                      logMsg("D", "Manage resources", "Tapped - add resource.");
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 10),
                        Icon(Icons.add, color: milkC, size: 28),
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
              )
            ],
          ),
          Material(
            color: milkC,
            shape: IOSLikeShape(15, side: BorderSide(width: 1, color: Colors.black.withValues(alpha: 0.3))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                  child: Row(children: [
                    Text("Фото", style: TxtStyles.bodyMedium.copyWith(color: blackC, fontWeight: FontWeight.w600)),
                    Text("Название", style: TxtStyles.bodyMedium.copyWith(color: blackC, fontWeight: FontWeight.w600)),
                    Text("Тип", style: TxtStyles.bodyMedium.copyWith(color: blackC, fontWeight: FontWeight.w600)),
                    Text("Действия", style: TxtStyles.bodyMedium.copyWith(color: blackC, fontWeight: FontWeight.w600)),
                  ],),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
