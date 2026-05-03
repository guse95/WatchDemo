import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/animated_menu.dart';
import 'package:frontend/elements/cls_checkbox.dart';
import 'package:frontend/elements/cls_textfield.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
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

class AddResourceMenu extends StatefulWidget {
  final VoidCallback onClose;

  const AddResourceMenu({super.key, required this.onClose});

  @override
  State<AddResourceMenu> createState() => _AddResourceMenuState();
}

class _AddResourceMenuState extends State<AddResourceMenu> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int selectedIndex = 0;

  final List<String> _tabNames = ["Комната", "Ноутбук", "Доска", "Проектор"];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController(text: "0");
  final TextEditingController _areaController = TextEditingController(text: "0");
  bool _isProjectorChecked = false;
  bool _isScreenChecked = false;
  bool _isTvChecked = false;
  bool _isBoardChecked = false;

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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Добавить ресурс", style: TxtStyles.h2.copyWith(color: darkGreenC)),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,

            labelPadding: const EdgeInsets.only(right: 24),
            padding: EdgeInsets.zero,

            overlayColor: WidgetStateProperty.all(Colors.transparent),
            splashFactory: NoSplash.splashFactory,

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
          const SizedBox(height: 12),
          ClsTextfield(controller: _nameController, hint: "Название"),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            minLines: 2,
            maxLength: 250,
            decoration: InputDecoration(
              labelText: 'Описание',
              labelStyle: TxtStyles.captionMedium.copyWith(color: blackC),
              floatingLabelStyle: TxtStyles.captionMedium.copyWith(color: accentGreenC),
              hintText: 'Введите описание...',
              hintStyle: TxtStyles.caption.copyWith(color: blackC),
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: accentGreenC, width: 2),
              ),
            ),
            style: TxtStyles.body.copyWith(color: lightBlackC),
          ),
          const SizedBox(height: 12),
          Text("Параметры", style: TxtStyles.h3.copyWith(color: darkGreenC)),
          const SizedBox(height: 8),

          // ROOM
          if (selectedIndex == 0) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Вместимость (чел):", style: TxtStyles.bodyMedium.copyWith(color: blackC)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 35,
                            child: TextField(
                              controller: _capacityController,
                              style: TxtStyles.body.copyWith(color: accentGreenC),
                              decoration: const InputDecoration(
                                // Убираем всё визуальное оформление поля
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                counterText: "",

                                // Убираем стандартные отступы
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLength: 3,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Площадь (м²):", style: TxtStyles.bodyMedium.copyWith(color: blackC)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 35,
                            child: TextField(
                              controller: _areaController,
                              style: TxtStyles.body.copyWith(color: accentGreenC),
                              decoration: const InputDecoration(
                                // Убираем всё визуальное оформление поля
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                counterText: "",

                                // Убираем стандартные отступы
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLength: 3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClsCheckbox(
                            value: _isProjectorChecked,
                            onChanged: (value) {
                              setState(() => _isProjectorChecked = value);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text("Проектор", style: TxtStyles.bodyMedium.copyWith(color: blackC)),
                        ],
                      ),
                      Row(
                        children: [
                          ClsCheckbox(
                            value: _isScreenChecked,
                            onChanged: (value) {
                              setState(() => _isScreenChecked = value);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text("Экран", style: TxtStyles.bodyMedium.copyWith(color: blackC)),
                        ],
                      ),
                      Row(
                        children: [
                          ClsCheckbox(
                            value: _isTvChecked,
                            onChanged: (value) {
                              setState(() => _isTvChecked = value);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text("Телевизор", style: TxtStyles.bodyMedium.copyWith(color: blackC)),
                        ],
                      ),
                      Row(
                        children: [
                          ClsCheckbox(
                            value: _isBoardChecked,
                            onChanged: (value) {
                              setState(() => _isBoardChecked = value);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text("Доска", style: TxtStyles.bodyMedium.copyWith(color: blackC)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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
                        height: 500,
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
