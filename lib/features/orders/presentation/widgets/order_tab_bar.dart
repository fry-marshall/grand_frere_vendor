import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrderTabBar extends StatelessWidget implements PreferredSizeWidget {
  const OrderTabBar({super.key, required this.controller});
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
