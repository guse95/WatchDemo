import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/txt_styles.dart';

class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 4) {
      digits = digits.substring(0, 4);
    }

    String formatted = digits;

    if (digits.length > 2) {
      formatted = '${digits.substring(0, 2)}:${digits.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;

  const TimeField({
    super.key,
    required this.controller,
    this.hintText = '16:00',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 5,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          TimeInputFormatter(),
        ],
        validator: validateTime,
        style: TxtStyles.bodyMedium.copyWith(color: lightBlackC),
        decoration: InputDecoration(
          hoverColor: accentGreenC.withValues(alpha: 0.2),
          counterText: '',
          hintText: hintText,
          hintStyle: TxtStyles.captionMedium.copyWith(color: lightBlackC.withValues(alpha: 0.7)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          filled: true,
          fillColor: Colors.white,
          errorStyle: const TextStyle(
            fontSize: 0,
            height: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: darkMilkC,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: darkMilkC,
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  static String? validateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Заполните';
    }

    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

    if (!regex.hasMatch(value)) {
      return 'Некорректное время';
    }

    return null;
  }
}