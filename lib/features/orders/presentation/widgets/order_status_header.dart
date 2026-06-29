import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/vendor_order.dart';

class OrderStatusHeader extends StatelessWidget {
  const OrderStatusHeader({super.key, required this.order});
  final VendorOrder order;

  String get _label {
    if (order.isPending) return 'En attente de validation';
    if (order.isValidated) return 'Validée — à encaisser';
    if (order.isCompleted) return 'Terminée';
    if (order.isCancelled) return 'Annulée';
    return 'Expirée';
  }

  IconData get _icon {
    if (order.isPending) return Icons.schedule_rounded;
    if (order.isValidated) return Icons.check_rounded;
    if (order.isCompleted) return Icons.done_all_rounded;
    return Icons.cancel_outlined;
  }

  Color get _bg {
    if (order.isPending) return AppColors.warningSurface;
    if (order.isValidated) return AppColors.violetSurface;
    if (order.isCompleted) return AppColors.successSurface;
    return AppColors.line;
  }

  Color get _fg {
    if (order.isPending) return AppColors.brown;
    if (order.isValidated) return AppColors.violetText;
    if (order.isCompleted) return AppColors.successText;
    return AppColors.mute;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(color: _bg, borderRadius: AppRadius.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icon, color: _fg, size: 16),
          SizedBox(width: AppSpacing.xs),
          Text(_label, style: AppTextStyles.body.copyWith(color: _fg)),
        ],
      ),
    );
  }
}
