import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flykeys/src/utils/custom_style.dart';

class CustomProgressCircle extends StatelessWidget {
  final double progress; // between 0 and 1

  CustomProgressCircle(this.progress);

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Container(
        width: 400,
        height: 400,
        child: Stack(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: 400,
                  height: 400,
                  child: CustomPaint(
                    painter: ProgressCirclePainter(this.progress),
                  ),
                ),
                new BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: new Container(
                    decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                  ),
                ),
              ],
            ),
            Container(
              width: 400,
              height: 400,
              child: CustomPaint(
                painter: BackgroundCirclePainter(),
              ),
            ),
            Container(
              width: 400,
              height: 400,
              child: CustomPaint(
                painter: ProgressCirclePainter(this.progress),
              ),
            ),
            Center(
              child: Text(
                ((progress*100).round()).toString()+'%',
                style: CustomStyle.loadingProgressMusicPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xff2F3340)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(200, 200), 100, paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ProgressCirclePainter extends CustomPainter {
  final double progress; // between 0 and 1

  ProgressCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // In your paint method
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(200, 0),
        Offset(200, 400),
        [
          Color(0xff48FED0),
          Color(0xff39B1FB),
        ],
      )
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // it is between 0 and 2*pi
    double arcSize = 2 * pi * this.progress;

    canvas.drawArc(ui.Rect.fromCircle(center: Offset(200, 200), radius: 100), -pi / 2, arcSize, false, paint);
    canvas.drawArc(ui.Rect.fromCircle(center: Offset(200, 200), radius: 100), -pi / 2, arcSize, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
