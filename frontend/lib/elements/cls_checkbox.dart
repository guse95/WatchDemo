import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';

class ClsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ClsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.15,
      child: Checkbox(
        value: value,
        onChanged: (newValue) {
          onChanged(newValue ?? false);
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentGreenC;
          }
          return Colors.transparent;
        }),
        checkColor: Colors.white,
        side: const BorderSide(
          color: accentGreenC,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}