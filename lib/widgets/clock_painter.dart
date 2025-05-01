import 'package:flutter/material.dart';
import 'dart:math';

class ClockPainter extends CustomPainter {
  final DateTime dateTime;

  ClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    // 時計の背景を描画
    paint.color = Colors.black.withAlpha((0.1 * 255).toInt());
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // 時針を描画
    paint.color = Colors.black;
    paint.strokeWidth = 6;
    paint.strokeCap = StrokeCap.round;
    // 時針の角度を計算
    double hourAngle =
        (dateTime.hour % 12) * 30.0 + dateTime.minute * 0.5; // 1時間で30度、1分で0.5度
    double hourX =
        centerX + radius * 0.5 * cos((hourAngle - 90) * pi / 180); // -90で12時を上に
    double hourY =
        centerY + radius * 0.5 * sin((hourAngle - 90) * pi / 180); // -90で12時を上に
    canvas.drawLine(Offset(centerX, centerY), Offset(hourX, hourY), paint);

    // 分針を描画
    paint.color = Colors.blue;
    paint.strokeWidth = 4;
    // 分針の角度を計算
    double minuteAngle = dateTime.minute * 6.0; // 1分で6度
    double minuteX =
        centerX +
        radius * 0.7 * cos((minuteAngle - 90) * pi / 180); // -90で12時を上に
    double minuteY =
        centerY +
        radius * 0.7 * sin((minuteAngle - 90) * pi / 180); // -90で12時を上に
    canvas.drawLine(Offset(centerX, centerY), Offset(minuteX, minuteY), paint);

    // 秒針を描画
    paint.color = Colors.red;
    paint.strokeWidth = 2;
    paint.strokeCap = StrokeCap.round;
    // 秒針の角度を計算
    double secondAngle = dateTime.second * 6.0; // 1秒で6度
    double secondX =
        centerX +
        radius * 0.8 * cos((secondAngle - 90) * pi / 180); // -90で12時を上に
    double secondY =
        centerY +
        radius * 0.8 * sin((secondAngle - 90) * pi / 180); // -90で12時を上に
    canvas.drawLine(Offset(centerX, centerY), Offset(secondX, secondY), paint);

    // 時計の数字を描画
    paint.color = Colors.black;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.fill;
    double fontSize = 20;

    // 1から12までの数字を描画
    for (int i = 1; i <= 12; i++) {
      double angle = (i * 30 - 90) * pi / 180; // 30度ずつ回転
      double x = centerX + radius * 0.85 * cos(angle); // 位置調整
      double y = centerY + radius * 0.85 * sin(angle); // 位置調整

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2), // 中央揃え
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // 時計を1秒ごとに更新
  }
}
