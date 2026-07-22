import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../vendor/presentation/cubit/vendor_cubit.dart';
import '../../../vendor/presentation/cubit/vendor_state.dart';
import '../../domain/entities/vendor_order.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/order_list.dart';
import '../widgets/order_tab_bar.dart';
import '../widgets/orders_error_state.dart';

// ── Day helpers ───────────────────────────────────────────────────────────────

const _weekdaysShort = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
const _months = [
  'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
  'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc',
];

DateTime _orderDay(VendorOrder order) {
  if (order.scheduledFor != null) {
    final parsed = DateTime.tryParse(order.scheduledFor!);
    if (parsed != null) return DateUtils.dateOnly(parsed.toLocal());
  }
  return DateUtils.dateOnly(order.createdAt.toLocal());
}

String _chipLabel(DateTime date) {
  final today = DateUtils.dateOnly(DateTime.now());
  if (date == today) return "Auj.";
  if (date == today.subtract(const Duration(days: 1))) return 'Hier';
  if (date == today.add(const Duration(days: 1))) return 'Demain';
  return '${_weekdaysShort[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';
}

List<DateTime> _currentWeekDays() {
  final today = DateUtils.dateOnly(DateTime.now());
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return [
    for (var i = 0; i < 5; i++) monday.add(Duration(days: i)),
  ].where((d) => !d.isBefore(today)).toList();
}

List<VendorOrder> _filterByDay(List<VendorOrder> orders, DateTime? day) {
  if (day == null) return orders;
  return orders.where((o) => _orderDay(o) == day).toList();
}

// ── Screen ────────────────────────────────────────────────────────────────────

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  DateTime? _selectedDay;

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

            final days = _currentWeekDays();

            return Column(
              children: [
                _DayFilterBar(
                  days: days,
                  selected: _selectedDay,
                  onSelect: (d) => setState(() => _selectedDay = d),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      OrderList(
                        orders: _filterByDay(loaded.pending, _selectedDay),
                        emptyLabel: 'Aucune commande en attente',
                        emptyIcon: Icons.inbox_outlined,
                        actionOrderId: loaded.actionOrderId,
                        onRefresh: () => context.read<OrdersCubit>().refresh(),
                      ),
                      OrderList(
                        orders: _filterByDay(loaded.validated, _selectedDay),
                        emptyLabel: 'Aucune commande validée',
                        emptyIcon: Icons.check_circle_outline_rounded,
                        onRefresh: () => context.read<OrdersCubit>().refresh(),
                      ),
                      OrderList(
                        orders: _filterByDay(loaded.completed, _selectedDay),
                        emptyLabel: 'Aucune commande terminée',
                        emptyIcon: Icons.history_rounded,
                        onRefresh: () => context.read<OrdersCubit>().refresh(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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

  Future<void> _pickDate(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: selected ?? today,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365)),
      selectableDayPredicate: (d) =>
          d.weekday != DateTime.saturday && d.weekday != DateTime.sunday,
    );
    if (picked != null) onSelect(DateUtils.dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final customDay = selected != null && !days.contains(selected)
        ? selected
        : null;

    return Container(
      color: AppColors.paper,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _Chip(
                    label: 'Tous',
                    active: selected == null,
                    onTap: () => onSelect(null),
                  ),
                  const SizedBox(width: 8),
                  ...days.map((day) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _Chip(
                          label: _chipLabel(day),
                          active: selected == day,
                          onTap: () => onSelect(selected == day ? null : day),
                        ),
                      )),
                  if (customDay != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _Chip(
                        label: _chipLabel(customDay),
                        active: true,
                        onTap: () => onSelect(null),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: customDay != null ? AppColors.maroon : AppColors.white,
                borderRadius: AppRadius.pill,
                border: Border.all(
                  color: customDay != null ? AppColors.maroon : AppColors.line,
                ),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: customDay != null ? AppColors.white : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

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
          border: Border.all(
            color: active ? AppColors.maroon : AppColors.line,
          ),
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
