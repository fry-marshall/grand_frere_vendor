import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class OrdersErrorState extends StatelessWidget {
  const OrdersErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.line, size: 48),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'Réessayer',
                  style: AppTextStyles.buttonSmall.copyWith(color: AppColors.brown),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
