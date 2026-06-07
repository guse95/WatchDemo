import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/date_picker_button.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/logic/resource_model.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/txt_styles.dart';

class ResourcePage extends StatefulWidget {
  final Resource resource;
  final VoidCallback onBack;

  const ResourcePage({super.key, required this.resource, required this.onBack});

  static const Map<String, String> imagePaths = {
    "room": "assets/images/back.jpg",
    "laptop": "assets/images/notebook.png",
    "board": "assets/images/board.png",
    "projector": "assets/images/projector.png",
  };

  @override
  State<ResourcePage> createState() => _ResourcePageState();
}

class _ResourcePageState extends State<ResourcePage> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
  }

  Widget _property({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: lightBlackC),
        const SizedBox(width: 8),
        Text(text, style: TxtStyles.bodyMedium.copyWith(color: lightBlackC, fontSize: 14)),
        const SizedBox(width: 38),
      ],
    );
  }

  Widget _resourceProps() {
    List<Widget> props = [];

    switch (widget.resource.type) {
      case "room":
        props.add(_property(icon: Icons.people_alt_rounded, text: "Вместимость: ${widget.resource.roomCapacity} чел"));
        props.add(_property(icon: Icons.aspect_ratio, text: "Площадь: ${widget.resource.roomArea} м²"));
        if (widget.resource.roomHasScreen!) {
          props.add(_property(icon: Icons.tv_rounded, text: "Экран"));
        }
        if (widget.resource.roomHasBoard!) {
          props.add(_property(icon: Icons.edit_rounded, text: "Доска"));
        }
        if (widget.resource.roomHasProjector!) {
          props.add(_property(icon: Icons.present_to_all, text: "Проектор"));
        }
        if (widget.resource.roomHasTV!) {
          props.add(_property(icon: Icons.connected_tv, text: "ТВ"));
        }
        break;

      case "laptop":
        props.add(_property(icon: Icons.open_in_full_rounded, text: "${widget.resource.notebookDiagonal} inch"));
        props.add(_property(icon: Icons.terminal, text: "${widget.resource.notebookOS}"));
        props.add(_property(icon: Icons.memory_rounded, text: "${widget.resource.notebookCPU}"));
        break;

      case "board":
        props.add(_property(icon: Icons.edit_rounded, text: "${widget.resource.boardType}"));
        props.add(_property(icon: Icons.straighten_rounded, text: "${widget.resource.boardWidth} на ${widget.resource.boardHeight}"));
        break;

      case "projector":
        props.add(_property(icon: Icons.high_quality, text: "${widget.resource.prjResolution}"));
        if (widget.resource.prjHdmi!) {
          props.add(_property(icon: Icons.settings_input_hdmi_rounded, text: "HDMI"));
        }
        if (widget.resource.prjDp!) {
          props.add(_property(icon: Icons.settings_input_hdmi_rounded, text: "DP"));
        }
        if (widget.resource.prjVga!) {
          props.add(_property(icon: Icons.settings_input_hdmi_rounded, text: "VGA"));
        }
        if (widget.resource.prjDvi!) {
          props.add(_property(icon: Icons.settings_input_hdmi_rounded, text: "DVI"));
        }
        break;

      default:
        break;
    }

    return Row(children: props);
  }

  @override
  Widget build(BuildContext context) {
    final double leftSideWidth = 400;

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: widget.onBack,
            child: Row(
              children: [
                Icon(Icons.arrow_back, size: 20, color: darkGreenC),
                const SizedBox(width: 6),
                Text("Назад к списку", style: TxtStyles.bodyMedium.copyWith(color: darkGreenC)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(widget.resource.name, style: TxtStyles.h1.copyWith(color: blackC)),
          const SizedBox(height: 12),
          _resourceProps(),
          const SizedBox(height: 40),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: leftSideWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: leftSideWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(image: AssetImage(ResourcePage.imagePaths[widget.resource.type]!), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text("Описание", style: TxtStyles.h3.copyWith(color: blackC, fontSize: 18)),
                      const SizedBox(height: 6),
                      Text(widget.resource.description, style: TxtStyles.body.copyWith(color: lightBlackC)),
                    ],
                  ),
                ),
                const SizedBox(width: 40),

                // Меню календаря
                Expanded(
                  child: Material(
                    shape: IOSLikeShape(15),
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // КАЛЕНДАРЬ
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Material(
                                      color: Colors.white,
                                      shape: IOSLikeShape(10, side: BorderSide(width: 1.2, color: darkMilkC)),
                                      clipBehavior: Clip.antiAlias,
                                      child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: InkWell(
                                          onTap: () {
                                            logMsg("D", "Calendar", "Prev day tapped.");
                                            final now = DateTime.now();
                                            final today = DateTime(now.year, now.month, now.day);
                                            final previous = selectedDate.subtract(const Duration(days: 1));
                                            if (previous.isBefore(today)) {
                                              return;
                                            }
                                            setState(() {
                                              selectedDate = previous;
                                            });
                                          },
                                          child: Icon(Icons.keyboard_arrow_left_rounded, size: 24, color: lightBlackC),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Material(
                                      color: Colors.white,
                                      shape: IOSLikeShape(10, side: BorderSide(width: 1.2, color: darkMilkC)),
                                      clipBehavior: Clip.antiAlias,
                                      child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: InkWell(
                                          onTap: () {
                                            logMsg("D", "Calendar", "Next day tapped.");
                                            final now = DateTime.now();
                                            final today = DateTime(now.year, now.month, now.day);
                                            final next = selectedDate.add(const Duration(days: 1));
                                            final lastAvailableDate = today.add(const Duration(days: 29));
                                            if (next.isAfter(lastAvailableDate)) {
                                              return;
                                            }
                                            setState(() {
                                              selectedDate = next;
                                            });
                                          },
                                          child: Icon(Icons.keyboard_arrow_right_rounded, size: 24, color: lightBlackC),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    DatePickerButton(
                                      initialDate: selectedDate,
                                      onChanged: (date) {
                                        setState(() {
                                          selectedDate = date;
                                        });
                                        logMsg("D", "Date picker", "Picked $selectedDate");
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // РАЗДЕЛИТЕЛЬ
                          VerticalDivider(width: 1, thickness: 1, color: darkMilkC),

                          // БРОНЬ
                          Expanded(flex: 2, child: Text("Right")),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
