import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/txt_styles.dart';

class PurposeField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;

  const PurposeField({
    super.key,
    required this.controller,
    this.hintText = 'Обсуждение проекта',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      minLines: 1,
      maxLines: 5,
      maxLength: 100,
      inputFormatters: [
        LengthLimitingTextInputFormatter(100),
      ],
      validator: validatePurpose,
      style: TxtStyles.bodyMedium.copyWith(
        color: lightBlackC,
      ),
      decoration: InputDecoration(
        hoverColor: accentGreenC.withValues(alpha: 0.2),
        counterText: '',
        hintText: hintText,
        hintStyle: TxtStyles.captionMedium.copyWith(
          color: lightBlackC.withValues(alpha: 0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
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
    );
  }

  static String? validatePurpose(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Заполните';
    }

    if (text.length > 100) {
      return 'Максимум 100 символов';
    }

    return null;
  }
}