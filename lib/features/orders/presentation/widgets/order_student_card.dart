import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/vendor_order.dart';

class OrderStudentCard extends StatelessWidget {
  const OrderStudentCard({super.key, required this.order});
  final VendorOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.violet, AppColors.violetDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.violetCard,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: AppRadius.sm,
            ),
            child:
                const Icon(Icons.school_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.studentClass.isNotEmpty
                      ? order.studentClass.toUpperCase()
                      : 'ÉLÈVE',
                  style: AppTextStyles.label
                      .copyWith(color: Colors.white.withAlpha(200)),
                ),
                Text(
                  order.studentFullName,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                if (order.scheduledFor != null)
                  Text(
                    'Prévu le ${order.scheduledFor}',
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white.withAlpha(180)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
