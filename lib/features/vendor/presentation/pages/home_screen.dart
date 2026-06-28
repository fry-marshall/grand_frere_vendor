import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../cubit/vendor_cubit.dart';
import '../cubit/vendor_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/vendor_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (ctx) {
        final cubit = getIt<DashboardCubit>();
        final vendorState = ctx.read<VendorCubit>().state;
        if (vendorState is VendorLoaded) {
          cubit.load(vendorState.vendor.id);
        }
        return cubit;
      },
      child: BlocListener<VendorCubit, VendorState>(
        listener: (context, state) {
          if (state is VendorLoaded) {
            context.read<DashboardCubit>().load(state.vendor.id);
          }
        },
        child: const _HomeBody(),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BlocBuilder<VendorCubit, VendorState>(
              builder: (_, state) => VendorHeader(
                vendor: state is VendorLoaded ? state.vendor : null,
              ),
            ),
            Expanded(
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (_, state) => switch (state) {
                  DashboardLoading() ||
                  DashboardInitial() =>
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    ),
                  DashboardError(:final message) => _ErrorBody(message),
                  DashboardLoaded(:final stats, :final balance) =>
                    ListView(
                      padding: EdgeInsets.fromLTRB(14, 0, 14, 110 + bottomPad),
                      children: [
                        KpiRow(stats: stats),
                        const SizedBox(height: 10),
                        BalanceCard(balance: balance),
                        const SizedBox(height: 20),
                        const DashboardSectionHeader('Commandes en cours'),
                        const SizedBox(height: 12),
                        const EmptyOrdersCard(),
                      ],
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.mute),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
