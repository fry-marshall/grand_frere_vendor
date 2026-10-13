import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/counter_preview.dart';

class CounterStudentCard extends StatelessWidget {
  const CounterStudentCard({super.key, required this.preview});
  final CounterPreview preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: AppRadius.sm,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.brown,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preview.fullName,
                      style: AppTextStyles.h3.copyWith(color: AppColors.ink),
                    ),
                    if (preview.studentClass != null)
                      Text(
                        preview.studentClass!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mute,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: AppRadius.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Peut dépenser aujourd'hui",
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.successText,
                  ),
                ),
                Text(
                  '${formatXof(preview.spendableToday)} FCFA',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.successText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
