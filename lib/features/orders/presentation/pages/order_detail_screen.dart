import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/vendor_order.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/order_items_card.dart';
import '../widgets/order_pending_actions.dart';
import '../widgets/order_status_header.dart';
import '../widgets/order_student_card.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.order});
  final VendorOrder order;

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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.maroon,
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            order.shortCode != null
                ? 'Commande #${order.shortCode}'
                : 'Détail commande',
            style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderStatusHeader(order: order),
              SizedBox(height: AppSpacing.md),
              OrderStudentCard(order: order),
              SizedBox(height: AppSpacing.md),
              OrderItemsCard(order: order),
              if (order.isPending) ...[
                SizedBox(height: AppSpacing.xl),
                OrderPendingActions(order: order),
              ],
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
