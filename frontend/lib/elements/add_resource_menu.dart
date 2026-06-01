import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/board_type_menu.dart';
import 'package:frontend/elements/cls_checkbox.dart';
import 'package:frontend/elements/cls_textfield.dart';
import 'package:frontend/elements/param_textfield.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/txt_styles.dart';

import 'animated_menu.dart';
import 'ios_like_clipper.dart';

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

  final TextEditingController _ntbOsController = TextEditingController();
  final TextEditingController _ntbCpuController = TextEditingController();
  final TextEditingController _ntbDiagController = TextEditingController();

  String? _brdType;
  final TextEditingController _brdWidthController = TextEditingController();
  final TextEditingController _brdHeightController = TextEditingController();
  final GlobalKey _boardTypeKey = GlobalKey();

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
          ]
          // НОУТБУК
          else if (selectedIndex == 1) ...[
            ParamLineField(label: "ОС", hint: "ОС", controller: _ntbOsController, requiredField: true),
            const SizedBox(height: 10),
            ParamLineField(label: "CPU", hint: "CPU", controller: _ntbCpuController, requiredField: true),
            const SizedBox(height: 10),
            ParamLineField(
              label: "Диагональ",
              hint: "CPU",
              controller: _ntbDiagController,
              requiredField: true,
              digitsOnly: true,
              maxLength: 4,
            ),
          ]
          // ДОСКА
          else if (selectedIndex == 2) ...[
            Row(
              children: [
                Text("Тип*:", style: TxtStyles.bodyMedium.copyWith(color: blackC)),
                const SizedBox(width: 12),
                GestureDetector(
                  key: _boardTypeKey,
                  onTap: () {
                    AnimatedMenu.show(
                      context: context,
                      anchorKey: _boardTypeKey,
                      width: 260,
                      height: 300,
                      backgroundColor: milkC,
                      preferredDirection: AnimatedMenuDirection.topCenter,
                      shape: IOSLikeShape(30),
                      builder: (context, close) {
                        return BoardTypeMenu(
                          selectedValue: _brdType,
                          onChanged: (type) {
                            setState(() => _brdType = type);
                          },
                          onClose: close,
                        );
                      },
                    );
                  },
                  child: Text(_brdType ?? "Выберите тип", style: TxtStyles.bodyMedium.copyWith(color: blackC)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ParamLineField(
              label: "Высота",
              hint: "Высота",
              controller: _brdHeightController,
              requiredField: true,
              digitsOnly: true,
              maxLength: 5,
            ),
            const SizedBox(height: 10),
            ParamLineField(
              label: "Ширина",
              hint: "Ширина",
              controller: _brdWidthController,
              requiredField: true,
              digitsOnly: true,
              maxLength: 5,
            ),
          ],
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: accentGreenC,
              shape: IOSLikeShape(14),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 45,
                child: InkWell(
                  onTap: () {
                    logMsg("D", "Manage resources", "Tapped - internal add resource.");
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 10),
                      Icon(Icons.add, color: milkC, size: 25),
                      const SizedBox(width: 4),
                      Text(
                        "Добавить",
                        style: TxtStyles.bodyMedium.copyWith(color: milkC, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
