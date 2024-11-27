import 'package:flutter/material.dart';

class MetaBanderaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double ancho = 60;
    const colorPrimario = Colors.black;
    const colorSecundario = Color.fromARGB(100, 255, 255, 255);
    final paint = Paint();
    final double cellWidth = size.width / ancho; //ancho
    final double cellHeight = size.height / 2;

    for (int i = 0; i < ancho; i++) {
      paint.color = i % 2 == 0 ? colorPrimario : colorSecundario;
      canvas.drawRect(
        Rect.fromLTWH(i * cellWidth, 0, cellWidth, cellHeight),
        paint,
      );
    }

    for (int i = 0; i < ancho; i++) {
      paint.color = i % 2 == 0 ? colorSecundario : colorPrimario;
      canvas.drawRect(
        Rect.fromLTWH(i * cellWidth, cellHeight, cellWidth, cellHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}