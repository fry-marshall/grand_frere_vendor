import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/vendor_order.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrderPendingActions extends StatelessWidget {
  const OrderPendingActions({super.key, required this.order});
  final VendorOrder order;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (ctx, state) {
        final isActing =
            state is OrdersLoaded && state.actionOrderId == order.id;

        if (isActing) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        return Column(
          children: [
            GestureDetector(
              onTap: () => ctx.read<OrdersCubit>().validateOrder(order.id),
              child: Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldDeep],
                  ),
                  borderRadius: AppRadius.pill,
                  boxShadow: AppShadows.md,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Valider la commande',
                  style: AppTextStyles.buttonLabel.copyWith(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => ctx.read<OrdersCubit>().cancelOrder(order.id),
              child: Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
                decoration: BoxDecoration(
                  color: AppColors.dangerSurface,
                  borderRadius: AppRadius.pill,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Annuler la commande',
                  style: AppTextStyles.buttonLabel
                      .copyWith(color: AppColors.dangerText),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
