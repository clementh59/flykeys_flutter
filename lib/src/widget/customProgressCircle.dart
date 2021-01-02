import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flykeys/src/utils/custom_style.dart';

class CustomProgressCircle extends StatelessWidget {
  final double progress; // between 0 and 1

  CustomProgressCircle(this.progress);

  @override
  Widget build(BuildContext context) {

    double size = MediaQuery.of(context).size.width;

    return Container(
      width: size,
      height: size,
      child: Stack(
        children: <Widget>[
          ClipRect(
            child: Stack(
              children: <Widget>[
                Container(
                  width: size,
                  height: size,
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
          ),
          Container(
            width: size,
            height: size,
            child: CustomPaint(
              painter: BackgroundCirclePainter(),
            ),
          ),
          Center(
            child: Stack(
              children: [
                Container(
                  width: size,
                  height: size,
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
        ],
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

    canvas.drawCircle(Offset(size.width/2, size.width/2), 100, paint1);
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
        Offset(size.width/2, 0),
        Offset(size.width/2, size.width),
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

    canvas.drawArc(ui.Rect.fromCircle(center: Offset(size.width/2, size.width/2), radius: 100), -pi / 2, arcSize, false, paint);
    canvas.drawArc(ui.Rect.fromCircle(center: Offset(size.width/2, size.width/2), radius: 100), -pi / 2, arcSize, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
