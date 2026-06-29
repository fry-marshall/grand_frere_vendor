import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/vendor_order.dart';
import '../cubit/orders_cubit.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.isActing});

  final VendorOrder order;
  final bool isActing;

  Color get _borderColor {
    if (order.isPending) return AppColors.gold;
    if (order.isValidated) return AppColors.violet;
    if (order.isCompleted) return AppColors.success;
    return AppColors.mute;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        Routes.orderDetail.replaceFirst(':id', order.id),
        extra: order,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.xs,
          border: Border(left: BorderSide(color: _borderColor, width: 4)),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (order.shortCode != null) ...[
                    Text(
                      '#${order.shortCode}',
                      style: AppTextStyles.mono
                          .copyWith(color: AppColors.maroon, fontSize: 13),
                    ),
                    Text(
                      ' · ',
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.mute),
                    ),
                  ],
                  Text(
                    order.studentClass,
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.mute),
                  ),
                  const Spacer(),
                  OrderStatusBadge(order: order),
                ],
              ),
              SizedBox(height: AppSpacing.micro),
              Text(
                order.studentFullName,
                style: AppTextStyles.cardTitle.copyWith(color: AppColors.ink),
              ),
              Text(
                order.itemsSummary,
                style: AppTextStyles.caption.copyWith(color: AppColors.mute),
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  OrderPaymentBadge(isCash: order.isCash),
                  const Spacer(),
                  Text(
                    '${formatXof(order.totalAmount)} FCFA',
                    style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
                  ),
                ],
              ),
              if (order.isPending) ...[
                SizedBox(height: AppSpacing.sm),
                const Divider(color: AppColors.line, height: 1),
                SizedBox(height: AppSpacing.sm),
                OrderActionRow(order: order, isActing: isActing),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.order});
  final VendorOrder order;

  String get _label {
    if (order.isPending) return 'En attente';
    if (order.isValidated) return 'Validée';
    if (order.isCompleted) return 'Terminée';
    if (order.isCancelled) return 'Annulée';
    return 'Expirée';
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.micro,
      ),
      decoration: BoxDecoration(color: _bg, borderRadius: AppRadius.pill),
      child: Text(_label, style: AppTextStyles.label.copyWith(color: _fg)),
    );
  }
}

class OrderPaymentBadge extends StatelessWidget {
  const OrderPaymentBadge({super.key, required this.isCash});
  final bool isCash;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.micro,
      ),
      decoration: BoxDecoration(
        color: isCash ? AppColors.infoSurface : AppColors.goldSoft,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCash
                ? Icons.payments_outlined
                : Icons.account_balance_wallet_outlined,
            size: 11,
            color: isCash ? AppColors.info : AppColors.brown,
          ),
          const SizedBox(width: 4),
          Text(
            isCash ? 'Cash' : 'Wallet',
            style: AppTextStyles.label.copyWith(
              color: isCash ? AppColors.info : AppColors.brown,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderActionRow extends StatelessWidget {
  const OrderActionRow({super.key, required this.order, required this.isActing});
  final VendorOrder order;
  final bool isActing;

  @override
  Widget build(BuildContext context) {
    if (isActing) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.read<OrdersCubit>().validateOrder(order.id),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldDeep],
                ),
                borderRadius: AppRadius.sm,
              ),
              alignment: Alignment.center,
              child: Text(
                'Valider',
                style: AppTextStyles.buttonSmall.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: () => context.read<OrdersCubit>().cancelOrder(order.id),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.dangerSurface,
              borderRadius: AppRadius.sm,
            ),
            child: Text(
              'Annuler',
              style:
                  AppTextStyles.buttonSmall.copyWith(color: AppColors.dangerText),
            ),
          ),
        ),
      ],
    );
  }
}
