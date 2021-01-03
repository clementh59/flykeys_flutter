import 'package:flutter/material.dart';
import 'package:flykeys/src/utils/custom_colors.dart';
import 'package:flykeys/src/widget/custom_widgets.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      body: SafeArea(
        child: Center(child: CustomWidgets.circularProgressIndicator()),
      ),
    );
  }
}
