import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../balance/presentation/cubit/balance_cubit.dart';
import '../../../balance/presentation/cubit/balance_state.dart';
import '../../../orders/domain/entities/vendor_order.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../orders/presentation/widgets/order_card.dart';
import '../../domain/entities/vendor_stats.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../cubit/vendor_cubit.dart';
import '../cubit/vendor_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/vendor_header.dart';

// ── Day helpers ───────────────────────────────────────────────────────────────

const _weekdays = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];
const _weekdaysShort = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
const _months = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];
const _monthsShort = [
  'Jan',
  'Fév',
  'Mar',
  'Avr',
  'Mai',
  'Juin',
  'Juil',
  'Août',
  'Sep',
  'Oct',
  'Nov',
  'Déc',
];

String _dayLabel(DateTime date) {
  final today = DateUtils.dateOnly(DateTime.now());
  if (date == today) return "Aujourd'hui";
  if (date == today.subtract(const Duration(days: 1))) return 'Hier';
  return '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';
}

String _chipLabel(DateTime date) {
  final today = DateUtils.dateOnly(DateTime.now());
  if (date == today) return "Auj.";
  if (date == today.subtract(const Duration(days: 1))) return 'Hier';
  if (date == today.add(const Duration(days: 1))) return 'Demain';
  return '${_weekdaysShort[date.weekday - 1]} ${date.day} ${_monthsShort[date.month - 1]}';
}

DateTime _orderDay(VendorOrder order) {
  if (order.scheduledFor != null) {
    final parsed = DateTime.tryParse(order.scheduledFor!);
    if (parsed != null) return DateUtils.dateOnly(parsed.toLocal());
  }
  return DateUtils.dateOnly(order.createdAt.toLocal());
}

List<DateTime> _uniqueDays(List<VendorOrder> orders) {
  final days = <DateTime>{};
  for (final o in orders) {
    days.add(_orderDay(o));
  }
  return days.toList()..sort();
}

Map<DateTime, List<VendorOrder>> _groupByDay(List<VendorOrder> orders) {
  final grouped = <DateTime, List<VendorOrder>>{};
  for (final order in orders) {
    (grouped[_orderDay(order)] ??= []).add(order);
  }
  for (final list in grouped.values) {
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  return Map.fromEntries(
    grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const _HomeBody();
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  DateTime? _selectedDay;

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
              child: RefreshIndicator(
                color: AppColors.gold,
                onRefresh: () {
                  final vendorState = context.read<VendorCubit>().state;
                  return Future.wait([
                    context.read<OrdersCubit>().refresh(),
                    context.read<BalanceCubit>().refresh(),
                    context.read<VendorCubit>().load(),
                    if (vendorState is VendorLoaded)
                      context.read<DashboardCubit>().load(
                        vendorState.vendor.id,
                      ),
                  ]);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(14, 0, 14, 110 + bottomPad),
                  children: [
                    // ── KPIs ──────────────────────────────────────────────
                    BlocBuilder<DashboardCubit, DashboardState>(
                      builder: (_, dashboardState) {
                        final stats = dashboardState is DashboardLoaded
                            ? dashboardState.stats
                            : const VendorStats(
                                todayOrderCount: 0,
                                todayRevenue: 0,
                              );
                        return KpiRow(stats: stats);
                      },
                    ),
                    const SizedBox(height: 10),
                    // ── Balance card ───────────────────────────────────────
                    BlocBuilder<BalanceCubit, BalanceState>(
                      builder: (_, state) {
                        if (state is! BalanceLoaded &&
                            state is! BalanceActionError) {
                          return const SizedBox.shrink();
                        }
                        final balance = state is BalanceLoaded
                            ? state.balance
                            : (state as BalanceActionError).previous.balance;
                        return BalanceCard(balance: balance);
                      },
                    ),
                    // ── Active orders ──────────────────────────────────────
                    const SizedBox(height: 20),
                    const DashboardSectionHeader('Commandes en cours'),
                    const SizedBox(height: 10),
                    BlocBuilder<VendorCubit, VendorState>(
                      builder: (_, vendorState) {
                        final isPending =
                            vendorState is VendorLoaded &&
                            vendorState.vendor.status != 'ACTIVE';
                        if (isPending) return const PendingOrdersCard();

                        return BlocBuilder<OrdersCubit, OrdersState>(
                          builder: (_, state) {
                            if (state is OrdersInitial ||
                                state is OrdersLoading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.gold,
                                  ),
                                ),
                              );
                            }
                            final List<VendorOrder> active;
                            final String? actionId;
                            if (state is OrdersLoaded) {
                              active = [...state.pending, ...state.validated];
                              actionId = state.actionOrderId;
                            } else if (state is OrdersActionError) {
                              active = [
                                ...state.previous.pending,
                                ...state.previous.validated,
                              ];
                              actionId = null;
                            } else {
                              active = [];
                              actionId = null;
                            }

                            if (active.isEmpty) {
                              return const EmptyOrdersCard();
                            }

                            final days = _uniqueDays(active);
                            final filtered = _selectedDay == null
                                ? active
                                : active
                                      .where(
                                        (o) => _orderDay(o) == _selectedDay,
                                      )
                                      .toList();
                            final grouped = _groupByDay(filtered);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Day filter chips
                                if (days.length > 1) ...[
                                  _DayFilterBar(
                                    days: days,
                                    selected: _selectedDay,
                                    onSelect: (d) =>
                                        setState(() => _selectedDay = d),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                // Grouped orders
                                for (final entry in grouped.entries) ...[
                                  _DayHeader(label: _dayLabel(entry.key)),
                                  const SizedBox(height: 8),
                                  for (final order in entry.value)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: OrderCard(
                                        order: order,
                                        isActing: actionId == order.id,
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Day filter bar ────────────────────────────────────────────────────────────

class _DayFilterBar extends StatelessWidget {
  const _DayFilterBar({
    required this.days,
    required this.selected,
    required this.onSelect,
  });

  final List<DateTime> days;
  final DateTime? selected;
  final ValueChanged<DateTime?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'Tous',
            active: selected == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          ...days.map(
            (day) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: _chipLabel(day),
                active: selected == day,
                onTap: () => onSelect(selected == day ? null : day),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.maroon : AppColors.white,
          borderRadius: AppRadius.pill,
          border: Border.all(color: active ? AppColors.maroon : AppColors.line),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: active ? AppColors.white : AppColors.ink,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

// ── Day section header ────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: AppColors.mute,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
