import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/app_notify.dart';
import 'package:frontend/elements/bookings_timetable.dart';
import 'package:frontend/elements/date_picker_button.dart';
import 'package:frontend/elements/date_plate.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/elements/purpose_field.dart';
import 'package:frontend/elements/time_field.dart';
import 'package:frontend/logic/booking_model.dart';
import 'package:frontend/logic/http_requests.dart';
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
  final TextEditingController startTimeController = TextEditingController();
  final GlobalKey<FormState> startFormKey = GlobalKey<FormState>();
  final TextEditingController stopTimeController = TextEditingController();
  final GlobalKey<FormState> stopFormKey = GlobalKey<FormState>();
  final TextEditingController purposeController = TextEditingController();
  final GlobalKey<FormState> purposeFormKey = GlobalKey<FormState>();

  String? _timeError;

  List<Booking>? _bookingsList;
  int _bookingsRequestId = 0;

  Future<void> _loadBookings(int id, DateTime day) async {
    final requestId = ++_bookingsRequestId;
    final bookings = await HttpRequests().fetchBookingsForResource(id: id, day: day);
    if (!mounted || requestId != _bookingsRequestId || !_isSameDate(selectedDate, day)) {
      return;
    }
    setState(() {
      _bookingsList = bookings;
    });
    if (kDebugMode) {
      for (var booking in bookings) {
        print(booking);
      }
    }
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month && first.day == second.day;
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
      _bookingsList = null;
    });
    _loadBookings(widget.resource.id, date);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    _loadBookings(widget.resource.id, selectedDate);
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

  bool isLaterThan08(String time) {
    final parts = time.split(':');

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final timeInMinutes = hour * 60 + minute;
    const minTimeInMinutes = 8 * 60; // 08:00

    return timeInMinutes > minTimeInMinutes;
  }

  bool isEarlierThan20(String time) {
    final parts = time.split(':');

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final timeInMinutes = hour * 60 + minute;
    const maxTimeInMinutes = 20 * 60; // 20:00

    return timeInMinutes < maxTimeInMinutes;
  }

  bool isGapValid(String from, String to) {
    final partsFrom = from.split(':');
    final hourF = int.parse(partsFrom[0]);
    final minuteF = int.parse(partsFrom[1]);

    final partsTo = to.split(':');
    final hourT = int.parse(partsTo[0]);
    final minuteT = int.parse(partsTo[1]);

    final minutesF = hourF * 60 + minuteF;
    final minutesT = hourT * 60 + minuteT;
    return (minutesT - minutesF) >= 30;
  }

  String buildBookingDateTimeString(DateTime selectedDate, String time) {
    final year = selectedDate.year.toString().padLeft(4, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    final day = selectedDate.day.toString().padLeft(2, '0');
    return '$year-$month-${day}T$time';
  }

  Future<void> _bookResource() async {
    setState(() {
      _timeError = null;
    });

    if (startTimeController.text.isEmpty || stopTimeController.text.isEmpty) {
      setState(() {
        _timeError = "Заполните время";
      });
      return;
    }
    String timeFrom = startTimeController.text;
    String timeTo = stopTimeController.text;
    if (!isLaterThan08(timeFrom)) {
      setState(() {
        _timeError = "Время начала не раньше 8:00";
      });
      return;
    }
    if (!isEarlierThan20(timeTo)) {
      setState(() {
        _timeError = "Время окончания не позже 20:00";
      });
      return;
    }
    if (!isGapValid(timeFrom, timeTo)) {
      setState(() {
        _timeError = "Промежуток не меньше 30 мин.";
      });
      return;
    }
    bool purposeValid = purposeFormKey.currentState!.validate();
    if (!purposeValid) {
      return;
    }

    String from = buildBookingDateTimeString(selectedDate, timeFrom);
    String to = buildBookingDateTimeString(selectedDate, timeTo);

    final r = await HttpRequests().bookResourceRequest(id: widget.resource.id, desc: purposeController.text, from: from, to: to);
    if (!mounted) return;
    if (r.statusCode == 200) {
      AppNotify.show(context, message: "Успешно забронировано.", type: NotifyType.success);
      startTimeController.text = "";
      stopTimeController.text = "";
      purposeController.text = "";
      await _loadBookings(widget.resource.id, selectedDate);
    } else if (r.statusCode == 409) {
      AppNotify.show(context, message: "Это время уже занято.", type: NotifyType.error);
      await _loadBookings(widget.resource.id, selectedDate);
    }
    else {
      AppNotify.show(context, message: "Произошла ошибка.", type: NotifyType.error);
      await _loadBookings(widget.resource.id, selectedDate);
    }
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
                                            _selectDate(previous);
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
                                            _selectDate(next);
                                          },
                                          child: Icon(Icons.keyboard_arrow_right_rounded, size: 24, color: lightBlackC),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    DatePickerButton(
                                      initialDate: selectedDate,
                                      allowPick: true,
                                      onChanged: (date) {
                                        _selectDate(date);
                                        logMsg("D", "Date picker", "Picked $selectedDate");
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 18, 6),
                                    child: BookingsTimetable(bookings: _bookingsList, date: selectedDate),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // РАЗДЕЛИТЕЛЬ
                          VerticalDivider(width: 1, thickness: 1, color: darkMilkC),

                          // БРОНЬ
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 18, 12, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Новое бронирование", style: TxtStyles.h3.copyWith(color: blackC)),
                                  const SizedBox(height: 18),
                                  Text(
                                    "Дата",
                                    style: TxtStyles.bodyMedium.copyWith(color: lightBlackC, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  DatePlate(initialDate: selectedDate),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Время начала",
                                              style: TxtStyles.bodyMedium.copyWith(color: lightBlackC, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 6),
                                            Form(
                                              key: startFormKey,
                                              child: TimeField(controller: startTimeController, hintText: "HH:MM"),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Время окончания",
                                              style: TxtStyles.bodyMedium.copyWith(color: lightBlackC, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 6),
                                            Form(
                                              key: stopFormKey,
                                              child: TimeField(controller: stopTimeController, hintText: "HH:MM"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_timeError != null) ...[
                                    const SizedBox(height: 6),
                                    Text(_timeError!, style: TxtStyles.captionMedium.copyWith(color: Colors.red)),
                                  ],
                                  const SizedBox(height: 18),
                                  Text(
                                    "Цель бронирования",
                                    style: TxtStyles.bodyMedium.copyWith(color: lightBlackC, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  Form(
                                    key: purposeFormKey,
                                    child: PurposeField(controller: purposeController),
                                  ),
                                  const SizedBox(height: 18),
                                  Material(
                                    color: accentGreenC,
                                    elevation: 2,
                                    clipBehavior: Clip.antiAlias,
                                    shape: IOSLikeShape(10),
                                    child: SizedBox(
                                      height: 48,
                                      width: double.infinity,
                                      child: InkWell(
                                        onTap: () async {
                                          logMsg("D", "Resource page", "Book button tapped.");
                                          await _bookResource();
                                        },
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Забронировать",
                                            style: TxtStyles.bodyMedium.copyWith(color: milkC, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}
