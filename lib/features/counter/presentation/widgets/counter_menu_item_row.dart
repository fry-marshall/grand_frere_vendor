import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../menu/domain/entities/vendor_item.dart';

class CounterMenuItemRow extends StatelessWidget {
  const CounterMenuItemRow({
    super.key,
    required this.item,
    required this.quantity,
    required this.enabled,
    required this.onIncrement,
    required this.onDecrement,
  });

  final VendorItem item;
  final int quantity;
  final bool enabled;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final selected = quantity > 0;
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.xs,
        border: Border.all(
          color: selected ? AppColors.gold : AppColors.white,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.cardTitle.copyWith(color: AppColors.ink),
                ),
                Text(
                  '${formatXof(item.price)} FCFA',
                  style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                ),
              ],
            ),
          ),
          _QuantityButton(
            icon: Icons.remove_rounded,
            onTap: enabled && selected ? onDecrement : null,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                color: selected ? AppColors.ink : AppColors.line,
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add_rounded,
            onTap: enabled ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? AppColors.goldSoft : AppColors.cream,
          borderRadius: AppRadius.pill,
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? AppColors.brown : AppColors.line,
        ),
      ),
    );
  }
}
