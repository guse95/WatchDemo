import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/app_notify.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/logic/booking_model.dart';
import 'package:frontend/logic/http_requests.dart';
import 'package:frontend/txt_styles.dart';

import '../elements/animated_menu.dart';
import '../elements/confirm_action_dialog.dart';

class MyBookingsPage extends StatefulWidget {
  final Future<List<Booking>> Function() bookingsLoader;

  const MyBookingsPage({super.key, required this.bookingsLoader});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  List<Booking>? _myBookings;
  Object? _loadError;

  Future<void> _loadMyBookings({bool showLoading = false}) async {
    if (showLoading) {
      setState(() {
        _myBookings = null;
        _loadError = null;
      });
    }

    try {
      final bookings = await widget.bookingsLoader();
      if (kDebugMode) {
        for (final booking in bookings) {
          print(booking);
        }
      }
      if (!mounted) return;
      setState(() {
        _myBookings = bookings;
        _loadError = null;
      });
    } catch (error, stackTrace) {
      debugPrint("Failed to load bookings: $error\n$stackTrace");
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _myBookings = const [];
      });
    }
  }

  Widget _buildContent() {
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 42, color: lightBlackC),
            const SizedBox(height: 12),
            Text("Не удалось загрузить бронирования", style: TxtStyles.bodyMedium.copyWith(color: blackC)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => _loadMyBookings(showLoading: true), child: const Text("Повторить")),
          ],
        ),
      );
    }

    if (_myBookings == null) {
      return const Center(child: CircularProgressIndicator(color: accentGreenC));
    }

    if (_myBookings!.isEmpty) {
      return Center(
        child: Text("У вас нет предстоящих бронирований", style: TxtStyles.body.copyWith(color: lightBlackC)),
      );
    }

    return ListView.separated(
      itemCount: _myBookings!.length,
      padding: const EdgeInsets.only(bottom: 8),
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        return _BookingCard(booking: _myBookings![index], onCancelled: _loadMyBookings,);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMyBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Мои бронирования", style: TxtStyles.h1.copyWith(color: blackC)),
          const SizedBox(height: 18),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}

class _BookingCard extends StatefulWidget {
  static const Color _cancelColor = Color(0xFFB54848);
  final Booking booking;
  final Future<void> Function() onCancelled;

  const _BookingCard({required this.booking, required this.onCancelled});

  static const Map<String, String> imagePaths = {
    "room": "assets/images/back.jpg",
    "laptop": "assets/images/notebook.png",
    "board": "assets/images/board.png",
    "projector": "assets/images/projector.png",
  };

  @override
  State<_BookingCard> createState() => _BookingCardState();

  static String _formatBookingPeriod(DateTime from, DateTime to) {
    if (_isSameDate(from, to)) {
      return "${_formatDate(from)}, ${_formatTime(from)} – ${_formatTime(to)}";
    }
    return "${_formatDateTime(from)} – ${_formatDateTime(to)}";
  }

  static String _formatDateTime(DateTime value) {
    return "${_formatDate(value)}, ${_formatTime(value)}";
  }

  static String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, "0");
    final month = value.month.toString().padLeft(2, "0");
    return "$day.$month.${value.year}";
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, "0");
    final minute = value.minute.toString().padLeft(2, "0");
    return "$hour:$minute";
  }

  static bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month && first.day == second.day;
  }
}

class _BookingCardState extends State<_BookingCard> {
  final GlobalKey _cancelButtonKey = GlobalKey();

  Future<void> _cancelBooking() async {
    final r = await HttpRequests().cancelBookingRequest(id: widget.booking.id);
    if (!mounted) return;
    if (r.statusCode == 200) {
      AppNotify.show(context, message: "Бронь отменена", type: NotifyType.success);
      await widget.onCancelled();
    } else {
      AppNotify.show(context, message: "Ошибка отмены брони", type: NotifyType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resourceName = widget.booking.resource?.name ?? "Ресурс #${widget.booking.resourceId}";

    return Material(
      elevation: 4,
      color: Colors.white,
      shape: IOSLikeShape(20),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        height: 150,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final imageWidth = compact ? 140.0 : 190.0;
            final actionWidth = compact ? 112.0 : 140.0;

            return Row(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: imageWidth,
                  height: double.infinity,
                  child: Image.asset(_BookingCard.imagePaths[widget.booking.resource!.type]!, fit: BoxFit.cover),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resourceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TxtStyles.h3.copyWith(color: blackC),
                        ),
                        const SizedBox(height: 8),
                        _BookingInfoRow(
                          icon: Icons.calendar_month_rounded,
                          text: _BookingCard._formatBookingPeriod(widget.booking.bookedFrom, widget.booking.bookedTo),
                        ),
                        const SizedBox(height: 6),
                        _BookingInfoRow(icon: Icons.history_rounded, text: "Оформлено: ${_BookingCard._formatDateTime(widget.booking.lastUpdateAt)}"),
                        const SizedBox(height: 6),
                        _BookingInfoRow(icon: Icons.notes_rounded, text: widget.booking.description, maxLines: 2),
                      ],
                    ),
                  ),
                ),
                Material(
                  key: _cancelButtonKey,
                  color: Colors.white,
                  shape: IOSLikeShape(20, side: BorderSide(width: 1, color: _BookingCard._cancelColor)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      AnimatedMenu.show(
                        context: context,
                        anchorKey: _cancelButtonKey,
                        width: 250,
                        height: 140,
                        backgroundColor: milkC,
                        preferredDirection: AnimatedMenuDirection.bottomCenter,
                        shape: IOSLikeShape(30),
                        builder: (context, close) {
                          return ConfirmActionDialog(
                            label: "Отменить?",
                            msg: "Действительно отменить эту бронь?",
                            onClose: close,
                            onResourceChange: _cancelBooking,
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      child: Row(
                        children: [
                          Icon(Icons.close_rounded, size: 22, color: _BookingCard._cancelColor),
                          const SizedBox(width: 8),
                          Text("Отмена", style: TxtStyles.bodyMedium.copyWith(color: _BookingCard._cancelColor)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int maxLines;

  const _BookingInfoRow({required this.icon, required this.text, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: lightBlackC),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: TxtStyles.bodySmall.copyWith(color: lightBlackC),
          ),
        ),
      ],
    );
  }
}
