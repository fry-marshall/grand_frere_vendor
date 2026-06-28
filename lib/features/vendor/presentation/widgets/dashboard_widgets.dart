import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/vendor_stats.dart';

// ── KPI row ───────────────────────────────────────────────────────────────────

class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.stats});
  final VendorStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: KpiCard(
            label: 'Commandes',
            value: '${stats.todayOrderCount}',
            sub: "aujourd'hui",
            tint: AppColors.gold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: KpiCard(
            label: 'Recettes',
            value: formatXof(stats.todayRevenue),
            sub: 'FCFA jour',
            tint: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: KpiCard(
            label: 'À encaisser',
            value: formatXof(stats.cashToCollect),
            sub: 'FCFA cash',
            tint: AppColors.carrot,
          ),
        ),
      ],
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.tint,
  });

  final String label;
  final String value;
  final String sub;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F5B1E0F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.body.copyWith(
              color: AppColors.mute,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.maroon,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            sub,
            style: AppTextStyles.body
                .copyWith(color: AppColors.brown, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Section header + empty state ──────────────────────────────────────────────

class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.maroon,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class EmptyOrdersCard extends StatelessWidget {
  const EmptyOrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A5B1E0F),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, color: AppColors.line, size: 40),
          const SizedBox(height: 12),
          Text(
            'Aucune commande en cours',
            style: AppTextStyles.body.copyWith(
              color: AppColors.mute,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Les nouvelles commandes apparaîtront ici.',
            style: AppTextStyles.caption.copyWith(color: AppColors.mute),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
