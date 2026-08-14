import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

const _pinLength = 4;

class CashinConfirmView extends StatefulWidget {
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
  State<CashinConfirmView> createState() => _CashinConfirmViewState();
}

class _CashinConfirmViewState extends State<CashinConfirmView> {
  final _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isSubmitting = widget.isSubmitting;
    final onCancel = widget.onCancel;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

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
          'Confirmation',
          style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              120 + bottomPad,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Validated badge ────────────────────────────────────
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.success,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Carte Grand-Frère reconnue',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.successText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // ── Student card ────────────────────────────────────────
                _StudentCard(order: order),
                SizedBox(height: AppSpacing.md),

                // ── Order receipt ───────────────────────────────────────
                _ReceiptCard(order: order),
                SizedBox(height: AppSpacing.md),

                // ── Card PIN ─────────────────────────────────────────────
                _PinField(controller: _pinCtrl, enabled: !isSubmitting),
              ],
            ),
          ),

          // ── Loading overlay ─────────────────────────────────────────
          if (isSubmitting)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x44000000),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ),
            ),

          // ── Bottom CTA ──────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(
              order: order,
              isSubmitting: isSubmitting,
              onCancel: onCancel,
              bottomPad: bottomPad,
              pinController: _pinCtrl,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Student card ──────────────────────────────────────────────────────────────

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
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.violetCard,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(28),
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CARTE GRAND-FRÈRE',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white.withAlpha(180),
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.studentFullName,
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
                if (order.shortCode != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '#${order.shortCode}',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withAlpha(160),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Payment method pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(28),
              borderRadius: AppRadius.pill,
              border: Border.all(color: Colors.white.withAlpha(50), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  order.isCash
                      ? Icons.payments_outlined
                      : Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  order.isCash ? 'Cash' : 'Wave',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white,
                    fontSize: 11,
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

// ── Receipt card ──────────────────────────────────────────────────────────────

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.order});
  final Order order;

  String _timeAgo() {
    final diff = DateTime.now().difference(order.createdAt);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return 'il y a ${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.goldSoft,
                    borderRadius: AppRadius.sm,
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande #${order.shortCode ?? order.id.substring(0, 6).toUpperCase()}',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        _timeAgo(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mute,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successSurface,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.successText,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: AppColors.line,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Items
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              children: order.items
                  .map((item) => _ItemRow(item: item))
                  .toList(),
            ),
          ),
          const Divider(
            color: AppColors.line,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Total
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total à encaisser',
                  style: AppTextStyles.body.copyWith(color: AppColors.mute),
                ),
                Text(
                  '${formatXof(order.totalAmount)} FCFA',
                  style: AppTextStyles.h2.copyWith(color: AppColors.maroon),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card PIN ─────────────────────────────────────────────────────────────────

class _PinField extends StatelessWidget {
  const _PinField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Code PIN de la carte',
            style: AppTextStyles.label.copyWith(color: AppColors.ink),
          ),
          SizedBox(height: AppSpacing.micro),
          Text(
            "Demande à l'élève de saisir son code à 4 chiffres pour confirmer.",
            style: AppTextStyles.caption.copyWith(color: AppColors.mute),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: enabled,
            autofocus: false,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: _pinLength,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.h2.copyWith(
              color: AppColors.ink,
              letterSpacing: 12,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••',
              hintStyle: AppTextStyles.h2.copyWith(
                color: AppColors.line,
                letterSpacing: 12,
              ),
              filled: true,
              fillColor: AppColors.paper,
              border: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide: const BorderSide(color: AppColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide: const BorderSide(color: AppColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.sm,
                borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: AppSpacing.inputVertical,
              ),
            ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: AppRadius.xs,
            ),
            alignment: Alignment.center,
            child: Text(
              '×${item.quantity}',
              style: AppTextStyles.label.copyWith(
                color: AppColors.brown,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
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

// ── Bottom CTA ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.order,
    required this.isSubmitting,
    required this.onCancel,
    required this.bottomPad,
    required this.pinController,
  });

  final Order order;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final double bottomPad;
  final TextEditingController pinController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm + bottomPad,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: pinController,
            builder: (_, pinValue, _) {
              final pinComplete = pinValue.text.length == _pinLength;
              return BlocBuilder<CashinCubit, CashinState>(
                builder: (ctx, _) {
                  final canSubmit = !isSubmitting && pinComplete;
                  return GestureDetector(
                    onTap: canSubmit
                        ? () => ctx.read<CashinCubit>().completeOrder(
                            order,
                            pin: pinController.text,
                          )
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.buttonVertical,
                      ),
                      decoration: BoxDecoration(
                        gradient: canSubmit
                            ? const LinearGradient(
                                colors: [AppColors.gold, AppColors.goldDeep],
                              )
                            : null,
                        color: canSubmit ? null : AppColors.line,
                        borderRadius: AppRadius.pill,
                        boxShadow: canSubmit ? AppShadows.button : null,
                      ),
                      alignment: Alignment.center,
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.gold,
                              ),
                            )
                          : Text(
                              'Encaisser ${formatXof(order.totalAmount)} FCFA',
                              style: AppTextStyles.buttonLabel.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              );
            },
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
