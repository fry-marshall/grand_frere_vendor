import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SignupNavBar extends StatelessWidget {
  const SignupNavBar({super.key, required this.step, required this.onBack});

  final int step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 22, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 26),
            color: AppColors.maroon,
            onPressed: onBack,
          ),
          const Spacer(),
          Text(
            'VENDEUR · $step/2',
            style: AppTextStyles.label.copyWith(
              color: AppColors.gold,
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class SignupStepBars extends StatelessWidget {
  const SignupStepBars({super.key, required this.filledCount});

  final int filledCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 2, 22, 18),
      child: Row(
        children: [
          Expanded(child: _Bar(filled: filledCount >= 1)),
          const SizedBox(width: 5),
          Expanded(child: _Bar(filled: filledCount >= 2)),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: filled ? AppColors.gold : AppColors.line,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
