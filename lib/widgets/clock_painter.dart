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
    paint.color = Colors.black.withOpacity(0.1);
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // 時針を描画 (スタイリッシュに変更)
    paint.color = Colors.black;
    paint.strokeWidth = 6; // より細く
    paint.strokeCap = StrokeCap.round; // 丸みを帯びたエッジに
    double hourAngle = (dateTime.hour % 12) * 30.0 + dateTime.minute * 0.5;
    double hourX = centerX + radius * 0.5 * cos(hourAngle * pi / 180);
    double hourY = centerY + radius * 0.5 * sin(hourAngle * pi / 180);
    canvas.drawLine(Offset(centerX, centerY), Offset(hourX, hourY), paint);

    // 分針を描画 (スタイリッシュに変更)
    paint.color = Colors.blue; // 色を変更
    paint.strokeWidth = 4; // より細く
    double minuteAngle = dateTime.minute * 6.0;
    double minuteX = centerX + radius * 0.7 * cos(minuteAngle * pi / 180);
    double minuteY = centerY + radius * 0.7 * sin(minuteAngle * pi / 180);
    canvas.drawLine(Offset(centerX, centerY), Offset(minuteX, minuteY), paint);

    // 秒針を描画 (スタイリッシュに変更)
    paint.color = Colors.red; // 秒針の色を変更
    paint.strokeWidth = 2;
    paint.strokeCap = StrokeCap.round; // 丸みを帯びたエッジに
    double secondAngle = dateTime.second * 6.0;
    double secondX = centerX + radius * 0.8 * cos(secondAngle * pi / 180);
    double secondY = centerY + radius * 0.8 * sin(secondAngle * pi / 180);
    canvas.drawLine(Offset(centerX, centerY), Offset(secondX, secondY), paint);

    // 時計の数字を描画
    paint.color = Colors.black;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.fill;
    double fontSize = 20;

    // 1から12までの数字を描画
    for (int i = 1; i <= 12; i++) {
      double angle = (i * 30) * pi / 180; // 30度ずつ回転
      double x = centerX + radius * 0.85 * cos(angle);
      double y = centerY + radius * 0.85 * sin(angle);

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
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // 時計を1秒ごとに更新
  }
}
