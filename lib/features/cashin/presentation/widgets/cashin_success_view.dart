import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/order.dart';

class CashinSuccessView extends StatelessWidget {
  const CashinSuccessView({super.key, required this.order});
  final Order order;

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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            // ── Icon ──────────────────────────────────────────────────
            Center(child: _SuccessIcon()),
            SizedBox(height: AppSpacing.xl),

            // ── Message ───────────────────────────────────────────────
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
                    style:
                        AppTextStyles.h3.copyWith(color: AppColors.maroon),
                  ),
                  const TextSpan(text: 'encaissés\nauprès de '),
                  TextSpan(
                    text: order.studentFullName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // ── Summary pill ──────────────────────────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadius.pill,
                  boxShadow: AppShadows.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_rounded,
                        color: AppColors.gold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '#${order.shortCode ?? order.id.substring(0, 6).toUpperCase()} · ${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // ── CTA ───────────────────────────────────────────────────
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.buttonVertical),
                decoration: BoxDecoration(
                  color: AppColors.maroon,
                  borderRadius: AppRadius.pill,
                  boxShadow: AppShadows.md,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Retour à l'accueil",
                  style: AppTextStyles.buttonLabel
                      .copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
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
