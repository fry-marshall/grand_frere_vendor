import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../cubit/cashin_cubit.dart';
import '../cubit/cashin_state.dart';

class CashinConfirmView extends StatelessWidget {
  const CashinConfirmView({
    super.key,
    required this.order,
    required this.isSubmitting,
    required this.onCancel,
  });

  final Order order;
  final bool isSubmitting;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: isSubmitting ? null : onCancel,
        ),
        title: Text(
          "Confirmer l'encaissement",
          style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
        ),
      ),
      body: Stack(
        children: [
          _ConfirmBody(order: order, isSubmitting: isSubmitting, onCancel: onCancel),
          if (isSubmitting)
            const ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
            ),
        ],
      ),
    );
  }
}

class _ConfirmBody extends StatelessWidget {
  const _ConfirmBody({
    required this.order,
    required this.isSubmitting,
    required this.onCancel,
  });

  final Order order;
  final bool isSubmitting;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RecognizedChip(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.md),
                _StudentCard(order: order),
                SizedBox(height: AppSpacing.md),
                _OrderCard(order: order),
              ],
            ),
          ),
        ),
        _BottomActions(order: order, isSubmitting: isSubmitting, onCancel: onCancel),
      ],
    );
  }
}

class _RecognizedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.micro,
            ),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: AppRadius.pill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_rounded, color: AppColors.success, size: 14),
                SizedBox(width: AppSpacing.micro),
                Text(
                  'Carte GF reconnue',
                  style: AppTextStyles.buttonSmall.copyWith(color: AppColors.successText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.order});
  final Order order;

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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(Icons.qr_code_rounded, color: Colors.white, size: 32),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CARTE GRAND-FRÈRE',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                Text(
                  order.studentFullName,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                if (order.shortCode != null)
                  Text(
                    '#${order.shortCode}',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

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
                'Commande #${order.shortCode ?? order.id.substring(0, 6)}',
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
              Text(
                'Total à débiter',
                style: AppTextStyles.body.copyWith(color: AppColors.mute),
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
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
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

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.order,
    required this.isSubmitting,
    required this.onCancel,
  });

  final Order order;
  final bool isSubmitting;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          BlocBuilder<CashinCubit, CashinState>(
            builder: (ctx, _) => GestureDetector(
              onTap: isSubmitting
                  ? null
                  : () => ctx.read<CashinCubit>().completeOrder(order),
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
                  'Encaisser ${formatXof(order.totalAmount)} FCFA',
                  style: AppTextStyles.buttonLabel.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: isSubmitting ? null : onCancel,
            child: Text(
              'Annuler',
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
            ),
          ),
        ],
      ),
    );
  }
}
