import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/vendor_order.dart';
import '../../domain/entities/vendor_order_item.dart';

class OrderItemsCard extends StatelessWidget {
  const OrderItemsCard({super.key, required this.order});
  final VendorOrder order;

  String _timeAgo() {
    final diff = DateTime.now().difference(order.createdAt);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return 'il y a ${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Articles commandés',
                style: AppTextStyles.h3.copyWith(color: AppColors.ink),
              ),
              Text(
                _timeAgo(),
                style: AppTextStyles.caption.copyWith(color: AppColors.mute),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.line, height: 1),
          SizedBox(height: AppSpacing.sm),
          ...order.items.map((item) => OrderItemRow(item: item)),
          const Divider(color: AppColors.line, height: 1),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Total',
                    style: AppTextStyles.body.copyWith(color: AppColors.mute),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  OrderPaymentChip(isCash: order.isCash),
                ],
              ),
              Text(
                '${formatXof(order.totalAmount)} FCFA',
                style:
                    AppTextStyles.cardBalance.copyWith(color: AppColors.maroon),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderItemRow extends StatelessWidget {
  const OrderItemRow({super.key, required this.item});
  final VendorOrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            '${item.quantity}×',
            style:
                AppTextStyles.mono.copyWith(color: AppColors.mute, fontSize: 13),
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.body.copyWith(color: AppColors.ink),
            ),
          ),
          Text(
            formatXof(item.subtotal),
            style: AppTextStyles.body.copyWith(
              color: AppColors.mute,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderPaymentChip extends StatelessWidget {
  const OrderPaymentChip({super.key, required this.isCash});
  final bool isCash;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: isCash ? AppColors.infoSurface : AppColors.goldSoft,
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        isCash ? 'Cash' : 'Wallet',
        style: AppTextStyles.label.copyWith(
          color: isCash ? AppColors.info : AppColors.brown,
        ),
      ),
    );
  }
}
