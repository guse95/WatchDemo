import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/txt_styles.dart';

class DatePlate extends StatelessWidget {
  final DateTime initialDate;

  const DatePlate({super.key, required this.initialDate});

  String _formatDate(DateTime date) {
    return '${date.day < 10 ? "0" : ""}${date.day}.${date.month < 10 ? "0" : ""}${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            _formatDate(initialDate),
            style: TxtStyles.captionMedium.copyWith(color: lightBlackC, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const Icon(Icons.calendar_today_outlined, size: 16, color: lightBlackC),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
