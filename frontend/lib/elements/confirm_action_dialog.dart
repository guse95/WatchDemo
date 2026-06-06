import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/elements/ios_like_clipper.dart';
import 'package:frontend/logic/service.dart';
import 'package:frontend/txt_styles.dart';

class ConfirmActionDialog extends StatelessWidget {
  final String label;
  final String msg;
  final VoidCallback onClose;
  final Future<void> Function() onResourceChange;

  const ConfirmActionDialog({super.key, required this.label, required this.msg, required this.onClose, required this.onResourceChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(label, style: TxtStyles.h3.copyWith(color: darkGreenC)),
          ),
          Text(msg, style: TxtStyles.body.copyWith(color: blackC)),
          const Spacer(),
          Row(
            children: [
              Spacer(),
              Material(
                shape: IOSLikeShape(20),
                clipBehavior: Clip.antiAlias,
                color: blackC,
                child: SizedBox(
                  width: 50,
                  height: 37,
                  child: InkWell(
                    onTap: () {
                      logMsg("D", "Confirm dialog", "NO - Cancelled");
                      onClose();
                    },
                    child: Center(child: Text("Нет", style: TxtStyles.body.copyWith(color: milkC))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                shape: IOSLikeShape(20),
                color: accentGreenC,
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 50,
                  height: 37,
                  child: InkWell(
                    onTap: () async {
                      logMsg("D", "Confirm dialog", "NO - Cancelled");
                      await onResourceChange();
                      onClose();
                    },
                    child: Center(child: Text("Да", style: TxtStyles.body.copyWith(color: milkC))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
