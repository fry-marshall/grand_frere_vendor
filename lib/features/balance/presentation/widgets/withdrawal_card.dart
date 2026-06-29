import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/vendor_withdrawal.dart';

class WithdrawalCard extends StatelessWidget {
  const WithdrawalCard({super.key, required this.withdrawal});
  final VendorWithdrawal withdrawal;

  String get _statusLabel {
    if (withdrawal.isPending) return 'En attente';
    if (withdrawal.isInProgress) return 'En cours';
    if (withdrawal.isSuccess) return 'Effectué';
    return 'Échoué';
  }

  Color get _statusBg {
    if (withdrawal.isPending) return AppColors.warningSurface;
    if (withdrawal.isInProgress) return AppColors.infoSurface;
    if (withdrawal.isSuccess) return AppColors.successSurface;
    return AppColors.dangerSurface;
  }

  Color get _statusFg {
    if (withdrawal.isPending) return AppColors.brown;
    if (withdrawal.isInProgress) return AppColors.info;
    if (withdrawal.isSuccess) return AppColors.successText;
    return AppColors.dangerText;
  }

  IconData get _statusIcon {
    if (withdrawal.isPending) return Icons.schedule_rounded;
    if (withdrawal.isInProgress) return Icons.sync_rounded;
    if (withdrawal.isSuccess) return Icons.check_circle_outline_rounded;
    return Icons.error_outline_rounded;
  }

  String _timeAgo() {
    final diff = DateTime.now().difference(withdrawal.createdAt);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 30) return 'il y a ${diff.inDays} j';
    return '${withdrawal.createdAt.day}/${withdrawal.createdAt.month}/${withdrawal.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: AppRadius.sm,
            ),
            child: Icon(_statusIcon, color: _statusFg, size: 22),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  withdrawal.waveNumber,
                  style: AppTextStyles.body.copyWith(color: AppColors.ink),
                ),
                Text(
                  _timeAgo(),
                  style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${formatXof(withdrawal.amount)} ${withdrawal.currency}',
                style: AppTextStyles.h3.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: AppSpacing.micro),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.micro,
                ),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  _statusLabel,
                  style: AppTextStyles.label.copyWith(color: _statusFg),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
