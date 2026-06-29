import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/vendor_order.dart';
import 'order_card.dart';

class OrderList extends StatelessWidget {
  const OrderList({
    super.key,
    required this.orders,
    required this.emptyLabel,
    required this.emptyIcon,
    required this.onRefresh,
    this.actionOrderId,
  });

  final List<VendorOrder> orders;
  final String emptyLabel;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;
  final String? actionOrderId;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        color: AppColors.gold,
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
            Icon(emptyIcon, color: AppColors.line, size: 48),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        itemCount: orders.length,
        itemBuilder: (_, i) => OrderCard(
          order: orders[i],
          isActing: actionOrderId == orders[i].id,
        ),
      ),
    );
  }
}
