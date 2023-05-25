import 'dart:math';

import 'package:flutter/material.dart';

class PersonShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..arcTo(rect, 0, pi, false)
      ..lineTo(size.width / 4, size.height / 2)
      ..lineTo(size.width / 4, size.height * 0.75)
      ..lineTo(size.width * 0.75, size.height * 0.75)
      ..lineTo(size.width * 0.75, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}