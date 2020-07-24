import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/utils/custom_style.dart';

class SearchTypeElement extends StatelessWidget {
  final String name;
  final bool chosen;
  final Function onTap;

  SearchTypeElement(this.name, this.chosen, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: chosen? CustomColors.blue : Colors.transparent)
            ),
            child: Text(
              name,
              style: chosen
                ? CustomStyle.textResultChosen
                : CustomStyle.textResultNotChosen,
            ),
          ),
        ],
      ),
    );
  }
}