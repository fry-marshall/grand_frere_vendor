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
import '../../../../core/router/routes.dart';
import '../../../vendor/presentation/cubit/vendor_cubit.dart';
import '../../../vendor/presentation/cubit/vendor_state.dart';
import '../../domain/entities/vendor_order.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

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
          bottom: _TabBar(controller: _tabs),
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (ctx, state) {
            if (state is OrdersInitial || state is OrdersLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            if (state is OrdersError) {
              return _ErrorState(
                message: state.message,
                onRetry: _load,
              );
            }

            final loaded = state is OrdersLoaded
                ? state
                : (state as OrdersActionError).previous;

            return TabBarView(
              controller: _tabs,
              children: [
                _OrderList(
                  orders: loaded.pending,
                  emptyLabel: 'Aucune commande en attente',
                  emptyIcon: Icons.inbox_outlined,
                  actionOrderId: loaded.actionOrderId,
                  onRefresh: () => context.read<OrdersCubit>().refresh(),
                ),
                _OrderList(
                  orders: loaded.validated,
                  emptyLabel: 'Aucune commande validée',
                  emptyIcon: Icons.check_circle_outline_rounded,
                  onRefresh: () => context.read<OrdersCubit>().refresh(),
                ),
                _OrderList(
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

// ── Tab bar ───────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget implements PreferredSizeWidget {
  const _TabBar({required this.controller});
  final TabController controller;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (_, state) {
        final pending = state is OrdersLoaded ? state.pending.length : 0;
        final validated = state is OrdersLoaded ? state.validated.length : 0;
        final completed = state is OrdersLoaded ? state.completed.length : 0;

        return TabBar(
          controller: controller,
          indicatorColor: AppColors.maroon,
          indicatorWeight: 2.5,
          labelStyle: AppTextStyles.tabActive,
          unselectedLabelStyle: AppTextStyles.tabInactive,
          labelColor: AppColors.maroon,
          unselectedLabelColor: AppColors.mute,
          dividerColor: AppColors.line,
          tabs: [
            Tab(text: 'En attente${pending > 0 ? ' ($pending)' : ''}'),
            Tab(text: 'Validées${validated > 0 ? ' ($validated)' : ''}'),
            Tab(text: 'Terminées${completed > 0 ? ' ($completed)' : ''}'),
          ],
        );
      },
    );
  }
}

// ── Order list ────────────────────────────────────────────────────────────────

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.emptyLabel,
    required this.emptyIcon,
    required this.onRefresh,
    this.actionOrderId,
  });

  final List<VendorOrder> orders;
  final String emptyLabel;
  final IconData emptyIcon;
  final Future<void> Function() onRefresh;
  final String? actionOrderId;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        color: AppColors.gold,
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
            Icon(emptyIcon, color: AppColors.line, size: 48),
            const SizedBox(height: 12),
            Text(
              emptyLabel,
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderCard(
          order: orders[i],
          isActing: actionOrderId == orders[i].id,
        ),
      ),
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.isActing});

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
          border: Border(
            left: BorderSide(color: _borderColor, width: 4),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (order.shortCode != null)
                    Text(
                      '#${order.shortCode}',
                      style: AppTextStyles.mono
                          .copyWith(color: AppColors.maroon, fontSize: 13),
                    ),
                  if (order.shortCode != null)
                    Text(
                      ' · ',
                      style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                    ),
                  Text(
                    order.studentClass,
                    style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                  ),
                  const Spacer(),
                  _StatusBadge(order: order),
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
                  _PaymentBadge(isCash: order.isCash),
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
                _ActionRow(order: order, isActing: isActing),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.order});
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
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: AppRadius.pill,
      ),
      child: Text(_label, style: AppTextStyles.label.copyWith(color: _fg)),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.isCash});
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
            isCash ? Icons.payments_outlined : Icons.account_balance_wallet_outlined,
            size: 11,
            color: isCash ? AppColors.info : AppColors.brown,
          ),
          SizedBox(width: 4),
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.order, required this.isActing});
  final VendorOrder order;
  final bool isActing;

  @override
  Widget build(BuildContext context) {
    if (isActing) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.gold,
          ),
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
              style: AppTextStyles.buttonSmall
                  .copyWith(color: AppColors.dangerText),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

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
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'Réessayer',
                  style: AppTextStyles.buttonSmall.copyWith(color: AppColors.brown),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
