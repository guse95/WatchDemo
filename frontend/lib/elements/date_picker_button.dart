import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/txt_styles.dart';

class DatePickerButton extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;

  const DatePickerButton({super.key, required this.initialDate, required this.onChanged});

  @override
  State<DatePickerButton> createState() => _DatePickerButtonState();
}

class _DatePickerButtonState extends State<DatePickerButton> {
  late DateTime lastDate;

  DateTime _clearTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    const months = ['янв', 'фев', 'мар', 'апр', 'мая', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void initState() {
    super.initState();
    lastDate = widget.initialDate.add(const Duration(days: 29));
  }

  Future<void> _openCalendar() async {
    final result = await showCalendarDatePicker2Dialog(
      context: context,
      value: [widget.initialDate],
      dialogSize: const Size(300, 300),
      borderRadius: BorderRadius.circular(15),
      dialogBackgroundColor: milkC,

      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        currentDate: widget.initialDate,
        firstDate: widget.initialDate,
        lastDate: lastDate,

        weekdayLabels: const ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'],

        // Цвет выбранного дня
        selectedDayHighlightColor: darkGreenC,

        // Текст выбранного дня
        selectedDayTextStyle: TxtStyles.bodyMedium.copyWith(color: milkC),

        // Обычные дни
        dayTextStyle: TxtStyles.body.copyWith(color: lightBlackC),

        // Дни недели сверху
        weekdayLabelTextStyle: TxtStyles.bodyMedium.copyWith(color: lightBlackC),

        // Заголовок месяца / года
        controlsTextStyle: TxtStyles.bodyMedium.copyWith(color: blackC),

        // Сегодняшний день
        todayTextStyle: TxtStyles.body.copyWith(color: lightBlackC),

        // Неактивные дни
        disabledDayTextStyle: TxtStyles.body.copyWith(color: lightBlackC.withValues(alpha: 0.6)),

        // Тексты кнопок
        okButton: Text('Выбрать', style: TxtStyles.bodyMedium.copyWith(color: darkGreenC)),
        cancelButton: Text('Отмена', style: TxtStyles.bodyMedium.copyWith(color: blackC)),

        disableModePicker: true,
        daySplashColor: accentGreenC.withValues(alpha: 0.4),
      ),
    );
    if (result == null || result.isEmpty || result.first == null) return;

    final pickedDate = _clearTime(result.first!);
    // setState(() {
    //   selectedDate = pickedDate;
    // });
    widget.onChanged(pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openCalendar,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: darkMilkC, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: lightBlackC),
            const SizedBox(width: 8),
            Text(
              _formatDate(widget.initialDate),
              style: TxtStyles.captionMedium.copyWith(color: lightBlackC, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
