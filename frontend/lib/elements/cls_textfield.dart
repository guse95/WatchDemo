import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/txt_styles.dart';
import 'ios_like_clipper.dart';

class ClsTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool digitsOnly;
  final bool hide;

  const ClsTextfield({
    super.key,
    required this.controller,
    required this.hint,
    this.errorText,
    this.onChanged,
    this.digitsOnly = false,
    this.hide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shape: IOSLikeShape(27),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 3, 6, 3),
        child: TextField(
          controller: controller,
          style: TxtStyles.bodyMedium.copyWith(color: blackC),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TxtStyles.caption.copyWith(color: blackC),
            errorText: errorText,
            border: InputBorder.none,
          ),
          onChanged: onChanged,
          inputFormatters: digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
          obscureText: hide,
        ),
      ),
    );
  }
}
