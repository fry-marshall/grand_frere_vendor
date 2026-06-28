import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SchoolSearchBar extends StatelessWidget {
  const SchoolSearchBar({
    super.key,
    required this.controller,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, _) {
        final hasText = value.text.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            // No border at rest — only gold ring when typing
            border: hasText
                ? Border.all(color: AppColors.gold, width: 1.5)
                : null,
            boxShadow: hasText
                ? [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(46),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.ink.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(painter: _SearchIconPainter()),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.ink, fontSize: 14, height: 1.0),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Rechercher une école ou une commune',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.mute,
                      fontSize: 14,
                      height: 1.0,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              if (hasText) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClear,
                  child: Text(
                    'Effacer',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mute,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// SVG: viewBox 0 0 24 24
// <circle cx="11" cy="11" r="7" strokeWidth="2"/>
// <path d="M20 20l-3.5-3.5" strokeLinecap="round" strokeWidth="2"/>
class _SearchIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = AppColors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(11 * s, 11 * s), 7 * s, paint);
    canvas.drawLine(Offset(20 * s, 20 * s), Offset(16.5 * s, 16.5 * s), paint);
  }

  @override
  bool shouldRepaint(_SearchIconPainter _) => false;
}
