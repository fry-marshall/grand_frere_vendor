import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../balance/presentation/cubit/balance_cubit.dart';
import '../../../menu/domain/entities/vendor_item.dart';
import '../../../menu/presentation/cubit/items_cubit.dart';
import '../../../menu/presentation/cubit/items_state.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../vendor/presentation/cubit/dashboard_cubit.dart';
import '../cubit/counter_cubit.dart';
import '../cubit/counter_state.dart';
import '../widgets/counter_cart_view.dart';
import '../widgets/counter_scan_view.dart';
import '../widgets/counter_success_view.dart';

/// Counter sale: scan a card, build a cart from the menu, the student types
/// their PIN and the sale is paid on the spot. [initialCardCode] skips the
/// scan when the card was already scanned (cashin with no pending order).
class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key, this.initialCardCode});

  final String? initialCardCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>(
      create: (_) {
        final cubit = getIt<CounterCubit>();
        if (initialCardCode != null) {
          cubit.lookup(initialCardCode!, _activeMenu());
        }
        return cubit;
      },
      child: const _CounterOrchestrator(),
    );
  }
}

List<VendorItem> _activeMenu() {
  final state = getIt<ItemsCubit>().state;
  return state is ItemsLoaded ? state.active : const [];
}

class _CounterOrchestrator extends StatelessWidget {
  const _CounterOrchestrator();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CounterCubit>();

    return BlocListener<CounterCubit, CounterState>(
      listenWhen: (_, s) =>
          s is CounterScanError || s is CounterSaleError || s is CounterSold,
      listener: (ctx, state) {
        switch (state) {
          case CounterScanError(:final message):
            AppToast.show(ctx, message, isError: true);
          case CounterSaleError(:final message):
            AppToast.show(ctx, message, isError: true);
            ctx.read<CounterCubit>().dismissError();
          case CounterSold():
            getIt<BalanceCubit>().refresh();
            getIt<OrdersCubit>().refresh();
            getIt<DashboardCubit>().refresh();
          default:
            break;
        }
      },
      child: BlocBuilder<CounterCubit, CounterState>(
        buildWhen: (_, s) => s is! CounterSaleError,
        builder: (ctx, state) => switch (state) {
          CounterReady() => CounterCartView(
            state: state,
            onBack: cubit.restart,
          ),
          CounterSold() => CounterSuccessView(
            state: state,
            onNewSale: cubit.restart,
            onDone: () => ctx.pop(),
          ),
          _ => CounterScanView(
            onDetected: (code) => cubit.lookup(code, _activeMenu()),
            onBack: () => ctx.pop(),
          ),
        },
      ),
    );
  }
}
