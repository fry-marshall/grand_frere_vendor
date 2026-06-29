import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../vendor/presentation/cubit/vendor_cubit.dart';
import '../../../vendor/presentation/cubit/vendor_state.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/order_list.dart';
import '../widgets/order_tab_bar.dart';
import '../widgets/orders_error_state.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final vs = context.read<VendorCubit>().state;
    if (vs is VendorLoaded) {
      context.read<OrdersCubit>().load(vs.vendor.id);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

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
          title: Text(
            'Mes commandes',
            style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
          ),
          actions: [
            BlocBuilder<OrdersCubit, OrdersState>(
              builder: (_, state) => IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: AppColors.maroon, size: 22),
                onPressed: state is OrdersLoading
                    ? null
                    : () => context.read<OrdersCubit>().refresh(),
              ),
            ),
          ],
          bottom: OrderTabBar(controller: _tabs),
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (ctx, state) {
            if (state is OrdersInitial || state is OrdersLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            if (state is OrdersError) {
              return OrdersErrorState(message: state.message, onRetry: _load);
            }

            final loaded = state is OrdersLoaded
                ? state
                : (state as OrdersActionError).previous;

            return TabBarView(
              controller: _tabs,
              children: [
                OrderList(
                  orders: loaded.pending,
                  emptyLabel: 'Aucune commande en attente',
                  emptyIcon: Icons.inbox_outlined,
                  actionOrderId: loaded.actionOrderId,
                  onRefresh: () => context.read<OrdersCubit>().refresh(),
                ),
                OrderList(
                  orders: loaded.validated,
                  emptyLabel: 'Aucune commande validée',
                  emptyIcon: Icons.check_circle_outline_rounded,
                  onRefresh: () => context.read<OrdersCubit>().refresh(),
                ),
                OrderList(
                  orders: loaded.completed,
                  emptyLabel: 'Aucune commande terminée',
                  emptyIcon: Icons.history_rounded,
                  onRefresh: () => context.read<OrdersCubit>().refresh(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
