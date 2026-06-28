import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../vendor/presentation/cubit/vendor_cubit.dart';
import '../../../vendor/presentation/cubit/vendor_state.dart';
import '../../domain/entities/pending_order.dart';
import '../../domain/repositories/cashin_repository.dart';

class CashinPickView extends StatefulWidget {
  const CashinPickView({
    super.key,
    required this.onScan,
    required this.onCode,
  });

  final VoidCallback onScan;
  final VoidCallback onCode;

  @override
  State<CashinPickView> createState() => _CashinPickViewState();
}

class _CashinPickViewState extends State<CashinPickView> {
  late final Future<List<PendingOrder>> _pendingFuture;

  @override
  void initState() {
    super.initState();
    final vendorState = context.read<VendorCubit>().state;
    _pendingFuture = vendorState is VendorLoaded
        ? getIt<CashinRepository>()
            .getPendingOrders(vendorState.vendor.id)
            .then((e) => e.fold((_) => <PendingOrder>[], (o) => o))
        : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.maroon, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Encaisser une commande',
          style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Demande à l'élève de présenter sa Carte GRAND-FRÈRE, ou de te donner le numéro de sa commande.",
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
            ),
            SizedBox(height: AppSpacing.lg),
            _OptionCard(
              badge: 'RECOMMANDÉ',
              badgeColor: AppColors.gold,
              icon: Icons.qr_code_scanner_rounded,
              iconBg: AppColors.goldSoft,
              iconColor: AppColors.gold,
              title: 'Scanner la carte',
              description: 'Pointe la caméra vers le QR code de la Carte GF.',
              onTap: widget.onScan,
            ),
            SizedBox(height: AppSpacing.sm),
            _OptionCard(
              badge: 'SANS CONTACT DIRECT',
              badgeColor: AppColors.mute,
              icon: Icons.dialpad_rounded,
              iconBg: AppColors.cream,
              iconColor: AppColors.brown,
              title: 'Saisir le n° de commande',
              description: "Tape les 4 chiffres dictés par l'élève.",
              onTap: widget.onCode,
            ),
            SizedBox(height: AppSpacing.xl),
            _PendingOrdersSection(future: _pendingFuture),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.badge,
    required this.badgeColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String badge;
  final Color badgeColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, borderRadius: AppRadius.sm),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge,
                    style: AppTextStyles.label.copyWith(color: badgeColor),
                  ),
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.mute, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PendingOrdersSection extends StatelessWidget {
  const _PendingOrdersSection({required this.future});
  final Future<List<PendingOrder>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PendingOrder>>(
      future: future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
            ),
          );
        }
        final orders = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "En attente d'encaissement",
                  style: AppTextStyles.h3.copyWith(color: AppColors.ink),
                ),
                Text(
                  '${orders.length} commande${orders.length != 1 ? 's' : ''}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            ...orders.map((o) => _PendingOrderItem(order: o)),
          ],
        );
      },
    );
  }
}

class _PendingOrderItem extends StatelessWidget {
  const _PendingOrderItem({required this.order});
  final PendingOrder order;

  @override
  Widget build(BuildContext context) {
    final initial = order.studentLastName.isNotEmpty
        ? '${order.studentLastName[0].toUpperCase()}.'
        : '';
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
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(right: AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.shortCode} · ${order.studentFirstName} $initial',
                  style: AppTextStyles.cardTitle.copyWith(color: AppColors.ink),
                ),
                Text(
                  order.itemsSummary,
                  style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                ),
              ],
            ),
          ),
          Text(
            formatXof(order.totalAmount),
            style: AppTextStyles.h3.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
