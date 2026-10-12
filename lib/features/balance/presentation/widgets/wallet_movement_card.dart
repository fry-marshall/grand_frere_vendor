import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/wallet_movement.dart';
import '../utils/time_ago.dart';

class WalletMovementCard extends StatelessWidget {
  const WalletMovementCard({super.key, required this.movement});
  final WalletMovement movement;

  String get _label {
    if (movement.isCashin) return 'Encaissement';
    if (movement.isWithdrawal) return 'Retrait';
    if (movement.isWithdrawalRefund) return 'Retrait remboursé';
    return 'Ajustement';
  }

  IconData get _icon {
    if (movement.isCashin) return Icons.point_of_sale_rounded;
    if (movement.isWithdrawal) return Icons.arrow_upward_rounded;
    if (movement.isWithdrawalRefund) return Icons.undo_rounded;
    return Icons.tune_rounded;
  }

  Color get _bg =>
      movement.isCredit ? AppColors.successSurface : AppColors.dangerSurface;

  Color get _fg =>
      movement.isCredit ? AppColors.successText : AppColors.dangerText;

  @override
  Widget build(BuildContext context) {
    final sign = movement.isCredit ? '+' : '-';

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
            decoration: BoxDecoration(color: _bg, borderRadius: AppRadius.sm),
            child: Icon(_icon, color: _fg, size: 22),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _label,
                  style: AppTextStyles.body.copyWith(color: AppColors.ink),
                ),
                Text(
                  timeAgo(movement.createdAt),
                  style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${formatXof(movement.amount.abs())} FCFA',
                style: AppTextStyles.h3.copyWith(color: _fg),
              ),
              SizedBox(height: AppSpacing.micro),
              Text(
                'Solde : ${formatXof(movement.balanceAfter)} FCFA',
                style: AppTextStyles.caption.copyWith(color: AppColors.mute),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
