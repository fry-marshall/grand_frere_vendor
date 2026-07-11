import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/vendor_order.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrderPendingActions extends StatelessWidget {
  const OrderPendingActions({super.key, required this.order});
  final VendorOrder order;

  Future<void> _confirm(BuildContext context, {required bool isValidation}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text(
          isValidation ? 'Valider la commande ?' : 'Annuler la commande ?',
          style: AppTextStyles.h2.copyWith(color: AppColors.ink),
        ),
        content: Text(
          isValidation
              ? 'La commande sera confirmée et le client en sera informé.'
              : 'La commande sera annulée. Cette action est irréversible.',
          style: AppTextStyles.body.copyWith(color: AppColors.mute),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Retour',
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              isValidation ? 'Valider' : 'Annuler',
              style: AppTextStyles.body.copyWith(
                color: isValidation ? AppColors.gold : AppColors.dangerText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<OrdersCubit>();
    if (isValidation) {
      await cubit.validateOrder(order.id);
    } else {
      await cubit.cancelOrder(order.id);
    }

    if (!context.mounted) return;
    if (cubit.state is! OrdersActionError) {
      AppToast.show(
        context,
        isValidation ? 'Commande validée' : 'Commande annulée',
        isError: !isValidation,
      );
      context.pop();
    }
  }

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
              onTap: () => _confirm(ctx, isValidation: true),
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
              onTap: () => _confirm(ctx, isValidation: false),
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
