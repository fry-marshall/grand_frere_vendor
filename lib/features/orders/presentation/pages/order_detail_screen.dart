import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/vendor_order.dart';
import '../../domain/entities/vendor_order_item.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});
  final VendorOrder order;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersCubit, OrdersState>(
      listener: (ctx, state) {
        if (state is OrdersActionError) {
          AppToast.show(ctx, state.message, isError: true);
          ctx.read<OrdersCubit>().dismissActionError();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.paper,
        appBar: AppBar(
          backgroundColor: AppColors.paper,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.maroon,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            order.shortCode != null
                ? 'Commande #${order.shortCode}'
                : 'Détail commande',
            style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusHeader(order: order),
              SizedBox(height: AppSpacing.md),
              _StudentCard(order: order),
              SizedBox(height: AppSpacing.md),
              _OrderItems(order: order),
              if (order.isPending) ...[
                SizedBox(height: AppSpacing.xl),
                _PendingActions(order: order),
              ],
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status header ─────────────────────────────────────────────────────────────

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order});
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

// ── Student card ──────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.order});
  final VendorOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.violet, AppColors.violetDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.violetCard,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.studentClass.isNotEmpty
                      ? order.studentClass.toUpperCase()
                      : 'ÉLÈVE',
                  style: AppTextStyles.label
                      .copyWith(color: Colors.white.withAlpha(200)),
                ),
                Text(
                  order.studentFullName,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                if (order.scheduledFor != null)
                  Text(
                    'Prévu le ${order.scheduledFor}',
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white.withAlpha(180)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order items ───────────────────────────────────────────────────────────────

class _OrderItems extends StatelessWidget {
  const _OrderItems({required this.order});
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
          ...order.items.map((item) => _ItemRow(item: item)),
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
                  _PaymentChip(isCash: order.isCash),
                ],
              ),
              Text(
                '${formatXof(order.totalAmount)} FCFA',
                style: AppTextStyles.cardBalance.copyWith(color: AppColors.maroon),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final VendorOrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            '${item.quantity}×',
            style: AppTextStyles.mono.copyWith(color: AppColors.mute, fontSize: 13),
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

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({required this.isCash});
  final bool isCash;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
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

// ── Pending actions ───────────────────────────────────────────────────────────

class _PendingActions extends StatelessWidget {
  const _PendingActions({required this.order});
  final VendorOrder order;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (ctx, state) {
        final isActing = state is OrdersLoaded && state.actionOrderId == order.id;

        if (isActing) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        return Column(
          children: [
            GestureDetector(
              onTap: () => ctx.read<OrdersCubit>().validateOrder(order.id),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldDeep],
                  ),
                  borderRadius: AppRadius.pill,
                  boxShadow: AppShadows.md,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Valider la commande',
                  style: AppTextStyles.buttonLabel.copyWith(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => ctx.read<OrdersCubit>().cancelOrder(order.id),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
                decoration: BoxDecoration(
                  color: AppColors.dangerSurface,
                  borderRadius: AppRadius.pill,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Annuler la commande',
                  style: AppTextStyles.buttonLabel.copyWith(color: AppColors.dangerText),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
