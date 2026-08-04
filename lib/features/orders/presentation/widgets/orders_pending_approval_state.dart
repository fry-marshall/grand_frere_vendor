import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shown instead of the orders/cashin flow while the vendor account is not
/// yet ACTIVE — the backend rejects every order-related call until then.
class OrdersPendingApprovalState extends StatelessWidget {
  const OrdersPendingApprovalState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              size: 56,
              color: AppColors.gold,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Compte en attente de validation',
              style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              "Vous pourrez recevoir et encaisser des commandes dès que l'équipe Grand Frère aura approuvé votre compte.",
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restaurant_menu_rounded,
                      color: AppColors.brown),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      "En attendant, préparez votre menu depuis l'onglet \"Menu\".",
                      style:
                          AppTextStyles.cardBody.copyWith(color: AppColors.brown),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
