import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SchoolIcon extends StatelessWidget {
  const SchoolIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CustomPaint(painter: _BuildingPainter()),
        ),
      ),
    );
  }
}

// SVG path from prototype: M3 21h18M5 21V10l7-5 7 5v11M10 21v-6h4v6
class _BuildingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = AppColors.maroon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(3 * s, 21 * s)
      ..lineTo(21 * s, 21 * s)
      ..moveTo(5 * s, 21 * s)
      ..lineTo(5 * s, 10 * s)
      ..relativeLineTo(7 * s, -5 * s)
      ..relativeLineTo(7 * s, 5 * s)
      ..lineTo(19 * s, 21 * s)
      ..moveTo(10 * s, 21 * s)
      ..lineTo(10 * s, 15 * s)
      ..lineTo(14 * s, 15 * s)
      ..lineTo(14 * s, 21 * s);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BuildingPainter _) => false;
}
