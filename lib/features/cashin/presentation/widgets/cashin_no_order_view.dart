import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// Shown when a scanned card has no order to cash in: offers to sell at the
/// counter with the same card instead.
class CashinNoOrderView extends StatelessWidget {
  const CashinNoOrderView({
    super.key,
    required this.onCounterSale,
    required this.onRescan,
    required this.onBack,
  });

  final VoidCallback onCounterSale;
  final VoidCallback onRescan;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.maroon,
            size: 28,
          ),
          onPressed: onBack,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xl + bottomPad,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.line,
              size: 64,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune commande en attente',
              textAlign: TextAlign.center,
              style: AppTextStyles.h2.copyWith(color: AppColors.maroon),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              "Cet élève n'a pas de commande à encaisser aujourd'hui. Tu peux lui vendre directement au comptoir.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
            ),
            const Spacer(),
            AppButton.primary(
              label: 'Vendre au comptoir',
              onPressed: onCounterSale,
            ),
            SizedBox(height: AppSpacing.sm),
            AppButton.outlined(
              label: 'Scanner une autre carte',
              onPressed: onRescan,
            ),
          ],
        ),
      ),
    );
  }
}
