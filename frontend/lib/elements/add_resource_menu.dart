import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/app_notify.dart';
import 'package:frontend/elements/board_type_menu.dart';
import 'package:frontend/elements/cls_checkbox.dart';
import 'package:frontend/elements/cls_textfield.dart';
import 'package:frontend/elements/param_textfield.dart';
import 'package:frontend/logic/http_requests.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/txt_styles.dart';

import 'animated_menu.dart';
import 'ios_like_clipper.dart';

class ParamCheck extends StatelessWidget {
  final bool check;
  final ValueChanged<bool> onChanged;
  final String title;

  const ParamCheck({super.key, required this.check, required this.onChanged, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClsCheckbox(value: check, onChanged: onChanged),
        const SizedBox(width: 8),
        Text(title, style: TxtStyles.bodyMedium.copyWith(color: blackC)),
      ],
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
  String? _nameError;
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  bool _isProjectorChecked = false;
  bool _isScreenChecked = false;
  bool _isTvChecked = false;
  bool _isBoardChecked = false;

  final TextEditingController _ntbOsController = TextEditingController();
  final TextEditingController _ntbCpuController = TextEditingController();
  final TextEditingController _ntbDiagController = TextEditingController();

  String? _brdType;
  bool _brdTypeError = false;
  final TextEditingController _brdWidthController = TextEditingController();
  final TextEditingController _brdHeightController = TextEditingController();
  final GlobalKey _boardTypeKey = GlobalKey();

  final TextEditingController _prjResolutionController = TextEditingController();
  bool _isHdmiChecked = false;
  bool _isDpChecked = false;
  bool _isVgaChecked = false;
  bool _isDviChecked = false;

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

  Future<void> _sendAddRequest() async {
    bool hasError = false;
    if (_nameController.text.isEmpty) {
      hasError = true;
      setState(() => _nameError = "Заполните поле");
    }

    bool isCapacityValid = _formKey.currentState!.validate();
    hasError = hasError || !isCapacityValid;

    if (_brdType == null && selectedIndex == 2) {
      hasError = true;
      _brdTypeError = true;
    }
    if (hasError) return;

    Map<String, dynamic> params = {};
    params["name"] = _nameController.text;
    params["description"] = _descriptionController.text;
    params["extra_attributes"] = {};

    switch (selectedIndex) {
      case 0:
        params["type"] = "room";
        params["extra_attributes"]["room-capacity"] = _capacityController.text;
        params["extra_attributes"]["room-area"] = _areaController.text;
        params["extra_attributes"]["room-has-projector"] = _isProjectorChecked.toString();
        params["extra_attributes"]["room-has-screen"] = _isScreenChecked.toString();
        params["extra_attributes"]["room-has-tv"] = _isTvChecked.toString();
        params["extra_attributes"]["room-has-board"] = _isBoardChecked.toString();
        break;
      case 1:
        params["type"] = "notebook";
        params["extra_attributes"]["notebook-os"] = _ntbOsController.text;
        params["extra_attributes"]["notebook-cpu"] = _ntbCpuController.text;
        params["extra_attributes"]["notebook-diagonal"] = _ntbDiagController.text;
        break;
      case 2:
        params["type"] = "board";
        params["extra_attributes"]["board-type"] = _brdType!;
        params["extra_attributes"]["board-height"] = _brdHeightController.text;
        params["extra_attributes"]["board-width"] = _brdWidthController.text;
        break;
      case 3:
        params["type"] = "projector";
        params["extra_attributes"]["projector-hdmi"] = _isHdmiChecked.toString();
        params["extra_attributes"]["projector-dp"] = _isDpChecked.toString();
        params["extra_attributes"]["projector-vga"] = _isVgaChecked.toString();
        params["extra_attributes"]["projector-dvi"] = _isDviChecked.toString();
        break;
      default:
        logMsg("E", "Send add resource request", "Unsupported resource type - $selectedIndex");
        break;
    }

    final r = await HttpRequests().sendAddResourceRequest(params: params);
    widget.onClose();

    if (r.statusCode == 200) {
      AppNotify.show(context, message: "Ресурс добавлен!", type: NotifyType.success);
    } else {
      AppNotify.show(context, message: "Ошибка добавления ресурса.", type: NotifyType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
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
            ClsTextfield(
              controller: _nameController,
              hint: "Название",
              errorText: _nameError,
              onChanged: (_) {
                setState(() => _nameError = null);
              },
            ),
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
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: ParamLineField(
                            key: const ValueKey('room_capacity'),
                            label: "Вместимость (чел)",
                            hint: "Вместимость",
                            controller: _capacityController,
                            requiredField: true,
                            maxLength: 4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: ParamLineField(
                            key: const ValueKey('room_area'),
                            label: "Площадь (м²)",
                            hint: "Площадь (м²)",
                            controller: _areaController,
                            requiredField: true,
                            maxLength: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        ParamCheck(
                          check: _isProjectorChecked,
                          onChanged: (check) {
                            setState(() => _isProjectorChecked = check);
                          },
                          title: "Проектор",
                        ),
                        ParamCheck(
                          check: _isScreenChecked,
                          onChanged: (check) {
                            setState(() => _isScreenChecked = check);
                          },
                          title: "Экран",
                        ),
                        ParamCheck(
                          check: _isTvChecked,
                          onChanged: (check) {
                            setState(() => _isTvChecked = check);
                          },
                          title: "Телевизор",
                        ),
                        ParamCheck(
                          check: _isBoardChecked,
                          onChanged: (check) {
                            setState(() => _isBoardChecked = check);
                          },
                          title: "Доска",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]
            // НОУТБУК
            else if (selectedIndex == 1) ...[
              ParamLineField(
                key: const ValueKey('notebook_os'),
                label: "ОС",
                hint: "ОС",
                controller: _ntbOsController,
                requiredField: true,
              ),
              const SizedBox(height: 10),
              ParamLineField(
                key: const ValueKey('notebook_cpu'),
                label: "CPU",
                hint: "CPU",
                controller: _ntbCpuController,
                requiredField: true,
              ),
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
                        width: 200,
                        height: 152,
                        backgroundColor: milkC,
                        preferredDirection: AnimatedMenuDirection.bottomCenter,
                        shape: IOSLikeShape(30),
                        builder: (context, close) {
                          return BoardTypeMenu(
                            selectedValue: _brdType,
                            onChanged: (type) {
                              setState(() {
                                _brdType = type;
                                _brdTypeError = false;
                              });
                            },
                            onClose: close,
                          );
                        },
                      );
                    },
                    child: Text(
                      _brdType ?? "Выберите тип",
                      style: TxtStyles.bodyMedium.copyWith(color: _brdType == null ? (_brdTypeError ? Colors.red : accentGreenC) : blackC),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ParamLineField(
                key: const ValueKey('board_height'),
                label: "Высота",
                hint: "Высота",
                controller: _brdHeightController,
                requiredField: true,
                digitsOnly: true,
                maxLength: 5,
              ),
              const SizedBox(height: 10),
              ParamLineField(
                key: const ValueKey('board_width'),
                label: "Ширина",
                hint: "Ширина",
                controller: _brdWidthController,
                requiredField: true,
                digitsOnly: true,
                maxLength: 5,
              ),
            ]
            // ПРОЕКТОР
            else if (selectedIndex == 3) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18),
                      child: ParamLineField(
                        key: const ValueKey('projector_resolution'),
                        label: "Разрешение",
                        hint: "Разрешение",
                        controller: _prjResolutionController,
                        requiredField: true,
                        maxLength: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        ParamCheck(
                          check: _isHdmiChecked,
                          onChanged: (check) {
                            setState(() => _isHdmiChecked = check);
                          },
                          title: "HDMI",
                        ),
                        ParamCheck(
                          check: _isDpChecked,
                          onChanged: (check) {
                            setState(() => _isDpChecked = check);
                          },
                          title: "DP",
                        ),
                        ParamCheck(
                          check: _isDviChecked,
                          onChanged: (check) {
                            setState(() => _isDviChecked = check);
                          },
                          title: "DVI",
                        ),
                        ParamCheck(
                          check: _isVgaChecked,
                          onChanged: (check) {
                            setState(() => _isVgaChecked = check);
                          },
                          title: "VGA",
                        ),
                      ],
                    ),
                  ),
                ],
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
                    onTap: () async {
                      logMsg("D", "Manage resources", "Tapped - internal add resource.");
                      await _sendAddRequest();
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
      ),
    );
  }
}
