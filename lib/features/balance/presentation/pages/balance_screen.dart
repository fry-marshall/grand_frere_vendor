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
import '../../../vendor/presentation/cubit/vendor_cubit.dart';
import '../../../vendor/presentation/cubit/vendor_state.dart';
import '../cubit/balance_cubit.dart';
import '../cubit/balance_state.dart';
import '../widgets/withdrawal_card.dart';
import '../widgets/withdrawal_form_sheet.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BalanceCubit, BalanceState>(
      listener: (ctx, state) {
        if (state is BalanceActionError) {
          AppToast.show(ctx, state.message, isError: true);
          ctx.read<BalanceCubit>().dismissError();
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
            'Solde & Retraits',
            style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
          ),
          actions: [
            BlocBuilder<BalanceCubit, BalanceState>(
              builder: (_, state) => IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.maroon, size: 22),
                onPressed: state is BalanceLoading
                    ? null
                    : () => context.read<BalanceCubit>().refresh(),
              ),
            ),
          ],
        ),
        body: BlocBuilder<BalanceCubit, BalanceState>(
          builder: (ctx, state) {
            if (state is BalanceInitial || state is BalanceLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            if (state is BalanceError) {
              return _ErrorState(
                message: state.message,
                onRetry: () => ctx.read<BalanceCubit>().refresh(),
              );
            }

            final loaded = state is BalanceLoaded
                ? state
                : (state as BalanceActionError).previous;

            final vendor = ctx.read<VendorCubit>().state;
            final waveNumber =
                vendor is VendorLoaded ? vendor.vendor.waveNumber : null;

            return RefreshIndicator(
              color: AppColors.gold,
              onRefresh: () => ctx.read<BalanceCubit>().refresh(),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                children: [
                  _BalanceHeader(
                    balance: loaded.balance.balance,
                    currency: loaded.balance.currency,
                    onWithdraw: () => WithdrawalFormSheet.show(
                      ctx,
                      waveNumber: waveNumber,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Text(
                        'Historique des retraits',
                        style: AppTextStyles.h3.copyWith(color: AppColors.ink),
                      ),
                      if (loaded.withdrawals.isNotEmpty) ...[
                        SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.micro,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldSoft,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            '${loaded.withdrawals.length}',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.brown),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  if (loaded.withdrawals.isEmpty)
                    _EmptyWithdrawals()
                  else
                    ...loaded.withdrawals
                        .map((w) => WithdrawalCard(withdrawal: w)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({
    required this.balance,
    required this.currency,
    required this.onWithdraw,
  });

  final int balance;
  final String currency;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.maroon, Color(0xFF7A2B15)],
        ),
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOLDE DISPONIBLE',
            style: AppTextStyles.label.copyWith(
              color: Colors.white54,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatXof(balance),
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                currency,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white60,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: onWithdraw,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.buttonSmallV,
                horizontal: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: AppRadius.pill,
                border: Border.all(color: Colors.white30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Demander un retrait',
                    style: AppTextStyles.buttonSmall
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWithdrawals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.history_rounded, color: AppColors.line, size: 44),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Aucun retrait pour le moment',
            style: AppTextStyles.body.copyWith(color: AppColors.mute),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.line, size: 48),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.buttonSmallV,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'Réessayer',
                  style: AppTextStyles.buttonSmall
                      .copyWith(color: AppColors.brown),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
