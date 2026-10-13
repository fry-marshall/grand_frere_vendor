import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../cubit/counter_state.dart';

class CounterSuccessView extends StatelessWidget {
  const CounterSuccessView({
    super.key,
    required this.state,
    required this.onNewSale,
    required this.onDone,
  });

  final CounterSold state;
  final VoidCallback onNewSale;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.paper,
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
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.successSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.successText,
                  size: 48,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Vente encaissée !',
              textAlign: TextAlign.center,
              style: AppTextStyles.h1.copyWith(color: AppColors.maroon),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              '${formatXof(state.total)} FCFA payés par ${state.preview.fullName}',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
            ),
            const Spacer(),
            AppButton.primary(label: 'Nouvelle vente', onPressed: onNewSale),
            SizedBox(height: AppSpacing.sm),
            AppButton.outlined(label: 'Terminer', onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
