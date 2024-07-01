import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArrowPainter extends CustomPainter {
  final Color color;
  final double angle; // Angle in radians
  final double length;
  final double headSize;

  ArrowPainter({
    required this.color,
    required this.angle,
    required this.length,
    this.headSize = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final startPoint = Offset(size.width / 2, size.height / 2);
    final endPoint = startPoint + Offset(length * math.cos(angle), length * math.sin(angle));

    canvas.drawLine(startPoint, endPoint, paint);

    // Draw arrow head
    final headAngle1 = angle + math.pi / 6;
    final headAngle2 = angle - math.pi / 6;
    final headPoint1 = endPoint - Offset(headSize * math.cos(headAngle1), headSize * math.sin(headAngle1));
    final headPoint2 = endPoint - Offset(headSize * math.cos(headAngle2), headSize * math.sin(headAngle2));

    final path = Path()
      ..moveTo(endPoint.dx, endPoint.dy)
      ..lineTo(headPoint1.dx, headPoint1.dy)
      ..lineTo(headPoint2.dx, headPoint2.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint whenever the angle or other properties change
  }
}