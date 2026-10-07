import 'package:flutter/material.dart';

class CardChipWidget extends StatelessWidget {
  final double width;
  final double height;

  const CardChipWidget({
    super.key,
    this.width = 44,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFDF7A),
            Color(0xFFE5A93C),
            Color(0xFFB87B1D),
            Color(0xFFFFDF7A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8C580E),
          width: 0.8,
        ),
      ),
      child: CustomPaint(
        painter: _ChipLinesPainter(),
      ),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B4307).withOpacity(0.7)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Outer chip groove
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(5, 4, size.width - 10, size.height - 8),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, paint);

    // Horizontal center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Vertical connecting cutouts
    canvas.drawLine(
      Offset(size.width * 0.35, 4),
      Offset(size.width * 0.35, size.height - 4),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 4),
      Offset(size.width * 0.65, size.height - 4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
