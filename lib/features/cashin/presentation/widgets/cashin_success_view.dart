import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/order.dart';

class CashinSuccessView extends StatelessWidget {
  const CashinSuccessView({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          _SuccessIcon(),
          SizedBox(height: AppSpacing.xl),
          Text(
            'Encaissement réussi !',
            style: AppTextStyles.h1.copyWith(color: AppColors.maroon),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xs),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
              children: [
                TextSpan(
                  text: '${formatXof(order.totalAmount)} FCFA ',
                  style: AppTextStyles.cardBalance.copyWith(color: AppColors.maroon),
                ),
                const TextSpan(text: 'reçus\nde '),
                TextSpan(
                  text: order.studentFullName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Spacer(),
          _DoneButton(),
        ],
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.success, AppColors.successText],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withAlpha(64),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 46),
    );
  }
}

class _DoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
        decoration: BoxDecoration(
          color: AppColors.maroon,
          borderRadius: AppRadius.md,
        ),
        child: Text(
          "Retour à l'accueil",
          textAlign: TextAlign.center,
          style: AppTextStyles.buttonLabel.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
