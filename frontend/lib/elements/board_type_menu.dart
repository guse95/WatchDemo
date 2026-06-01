import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/txt_styles.dart';

class BoardTypeMenu extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const BoardTypeMenu({super.key, this.selectedValue, required this.onChanged, required this.onClose});

  @override
  Widget build(BuildContext context) {
    List<String> types = ["Маркерная", "Меловая", "Флипчарт"];
    List<String> iconPaths = ["assets/icons/marker.svg", "assets/icons/chalk.svg", "assets/icons/flipchart.svg"];

    return ListView.separated(
      itemCount: types.length,
      itemBuilder: (context, index) {
        return Material(
          color: selectedValue == types[index] ? accentGreenC : milkC,
          child: InkWell(
            onTap: () {
              onChanged.call(types[index]);
              onClose();
            },
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  SvgPicture.asset(iconPaths[index], width: 32, colorFilter: ColorFilter.mode(blackC, BlendMode.srcATop)),
                  const SizedBox(width: 8),
                  Text(types[index], style: TxtStyles.body.copyWith(color: blackC)),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Container(height: 1, color: darkGreenC);
      },
    );
  }
}
