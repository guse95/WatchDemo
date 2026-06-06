import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/txt_styles.dart';

class ParamLineField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool requiredField;
  final int maxLength;
  final bool digitsOnly;

  const ParamLineField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLength = 50,
    this.requiredField = false,
    this.digitsOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(requiredField ? '$label*:' : '$label:', style: TxtStyles.bodyMedium.copyWith(color: blackC)),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            maxLength: maxLength,
            validator: requiredField
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Заполните поле';
                    }
                    return null;
                  }
                : null,
            inputFormatters: digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
            decoration: const InputDecoration(
              isDense: true,
              counterText: '',
              contentPadding: EdgeInsets.only(bottom: 6),
              border: UnderlineInputBorder(borderSide: BorderSide(color: darkMilkC, width: 1)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: darkMilkC, width: 1)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentGreenC, width: 1.5)),
              errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.5)),
            ),
            style: TxtStyles.bodyMedium.copyWith(color: blackC),
          ),
        ),
      ],
    );
  }
}
