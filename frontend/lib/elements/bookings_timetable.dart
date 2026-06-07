import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/logic/booking_model.dart';
import 'package:frontend/txt_styles.dart';

class BookingsTimetable extends StatefulWidget {
  final List<Booking>? bookings;
  final DateTime date;

  const BookingsTimetable({
    super.key,
    required this.bookings,
    required this.date,
  });

  @override
  State<BookingsTimetable> createState() => _BookingsTimetableState();
}

class _BookingsTimetableState extends State<BookingsTimetable> {
  static const int _startHour = 8;
  static const int _endHour = 20;
  static const double _timeScaleWidth = 56;
  static const double _scheduleGap = 8;
  static const Color _lightGreen = Color(0xFFE7F1E3);
  static const Color _lightYellow = Color(0xFFFFF2C9);
  static const Color _darkYellow = Color(0xFF7A5A00);

  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bookings == null) {
      return const ColoredBox(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator(color: darkGreenC)),
      );
    }

    return ColoredBox(
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final verticalInset = math.min(9.0, constraints.maxHeight / 2);
          final timelineHeight = math.max(
            0.0,
            constraints.maxHeight - verticalInset * 2,
          );
          final hourHeight = timelineHeight / (_endHour - _startHour);
          final scaleWidth = math.min(
            _timeScaleWidth,
            constraints.maxWidth * 0.25,
          );
          final scheduleLeft = scaleWidth + _scheduleGap;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              ..._buildHourRows(
                hourHeight: hourHeight,
                verticalInset: verticalInset,
                scaleWidth: scaleWidth,
                scheduleLeft: scheduleLeft,
              ),
              ..._buildBookingCards(
                timelineHeight: timelineHeight,
                hourHeight: hourHeight,
                verticalInset: verticalInset,
                scheduleLeft: scheduleLeft,
              ),
              if (_shouldShowCurrentTime())
                ..._buildCurrentTimeIndicator(
                  hourHeight: hourHeight,
                  verticalInset: verticalInset,
                  scheduleLeft: scheduleLeft,
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildHourRows({
    required double hourHeight,
    required double verticalInset,
    required double scaleWidth,
    required double scheduleLeft,
  }) {
    return [
      for (var hour = _startHour; hour <= _endHour; hour++) ...[
        Positioned(
          top: verticalInset + (hour - _startHour) * hourHeight - 9,
          left: 4,
          width: scaleWidth,
          height: 18,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TxtStyles.calendarTime.copyWith(color: lightBlackC),
            ),
          ),
        ),
        Positioned(
          top: verticalInset + (hour - _startHour) * hourHeight,
          left: scheduleLeft,
          right: 0,
          child: const Divider(height: 1, thickness: 1, color: darkMilkC),
        ),
      ],
    ];
  }

  List<Widget> _buildBookingCards({
    required double timelineHeight,
    required double hourHeight,
    required double verticalInset,
    required double scheduleLeft,
  }) {
    final dayStart = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _startHour,
    );
    final dayEnd = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _endHour,
    );
    final visibleBookings =
        widget.bookings!
            .map(
              (booking) => (
                booking: booking,
                start: _asLocal(booking.bookedFrom),
                end: _asLocal(booking.bookedTo),
              ),
            )
            .where(
              (item) =>
                  item.end.isAfter(item.start) &&
                  item.start.isBefore(dayEnd) &&
                  item.end.isAfter(dayStart),
            )
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));

    return [
      for (var index = 0; index < visibleBookings.length; index++)
        _buildBookingCard(
          description: visibleBookings[index].booking.description,
          bookingStart: visibleBookings[index].start,
          bookingEnd: visibleBookings[index].end,
          dayStart: dayStart,
          dayEnd: dayEnd,
          color: index.isEven ? _lightGreen : _lightYellow,
          textColor: index.isEven ? darkGreenC : _darkYellow,
          timelineHeight: timelineHeight,
          hourHeight: hourHeight,
          verticalInset: verticalInset,
          scheduleLeft: scheduleLeft,
        ),
    ];
  }

  Widget _buildBookingCard({
    required String description,
    required DateTime bookingStart,
    required DateTime bookingEnd,
    required DateTime dayStart,
    required DateTime dayEnd,
    required Color color,
    required Color textColor,
    required double timelineHeight,
    required double hourHeight,
    required double verticalInset,
    required double scheduleLeft,
  }) {
    final visibleStart = bookingStart.isBefore(dayStart)
        ? dayStart
        : bookingStart;
    final visibleEnd = bookingEnd.isAfter(dayEnd) ? dayEnd : bookingEnd;
    final minutesFromStart = visibleStart.difference(dayStart).inMinutes;
    final durationInMinutes = visibleEnd.difference(visibleStart).inMinutes;
    final top = verticalInset + minutesFromStart / 60 * hourHeight;
    final height = math.min(
      durationInMinutes / 60 * hourHeight,
      verticalInset + timelineHeight - top,
    );

    return Positioned(
      top: top,
      left: scheduleLeft + 4,
      right: 4,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: ColoredBox(
          color: color,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final verticalPadding = constraints.maxHeight >= 40 ? 6.0 : 2.0;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TxtStyles.calendarEventTitle.copyWith(
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${_formatTime(bookingStart)} – ${_formatTime(bookingEnd)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TxtStyles.calendarEventTime.copyWith(
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _shouldShowCurrentTime() {
    return _isSameDate(widget.date, _now) &&
        _now.hour >= _startHour &&
        (_now.hour < _endHour || (_now.hour == _endHour && _now.minute == 0));
  }

  List<Widget> _buildCurrentTimeIndicator({
    required double hourHeight,
    required double verticalInset,
    required double scheduleLeft,
  }) {
    final minutesFromStart =
        (_now.hour - _startHour) * 60 + _now.minute + _now.second / 60;
    final top = verticalInset + minutesFromStart / 60 * hourHeight;

    return [
      Positioned(
        top: top - 1,
        left: scheduleLeft,
        right: 0,
        child: Container(height: 2, color: Colors.red),
      ),
      Positioned(
        top: top - 5,
        left: scheduleLeft - 5,
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }

  DateTime _asLocal(DateTime value) => value.isUtc ? value.toLocal() : value;

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
