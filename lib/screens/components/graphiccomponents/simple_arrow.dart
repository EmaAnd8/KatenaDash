import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArrowPainter extends CustomPainter {
  final Color color;
  final double angle;
  final double length;
  //final String label;

  ArrowPainter({required this.color, required this.angle, required this.length,/*required this.label*/});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(length * math.cos(angle), length * math.sin(angle));
    path.lineTo(length * math.cos(angle) - 5 * math.cos(angle - math.pi / 6),
        length * math.sin(angle) - 5 * math.sin(angle - math.pi / 6));
    path.moveTo(length * math.cos(angle), length * math.sin(angle));
    path.lineTo(length * math.cos(angle) - 5 * math.cos(angle + math.pi / 6),
        length * math.sin(angle) - 5 * math.sin(angle + math.pi / 6));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}