import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../cubit/counter_cubit.dart';
import '../cubit/counter_state.dart';
import 'counter_menu_item_row.dart';
import 'counter_pin_field.dart';
import 'counter_student_card.dart';

class CounterCartView extends StatefulWidget {
  const CounterCartView({super.key, required this.state, required this.onBack});

  final CounterReady state;
  final VoidCallback onBack;

  @override
  State<CounterCartView> createState() => _CounterCartViewState();
}

class _CounterCartViewState extends State<CounterCartView> {
  final _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = context.read<CounterCubit>();

    return BlocListener<CounterCubit, CounterState>(
      // A rejected sale (wrong PIN…) clears the PIN so it is retyped.
      listenWhen: (_, s) => s is CounterSaleError,
      listener: (_, _) => _pinCtrl.clear(),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        appBar: AppBar(
          backgroundColor: AppColors.paper,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.maroon,
              size: 28,
            ),
            onPressed: state.isSubmitting ? null : widget.onBack,
          ),
          title: Text(
            'Vente au comptoir',
            style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            CounterStudentCard(preview: state.preview),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Articles',
              style: AppTextStyles.h3.copyWith(color: AppColors.ink),
            ),
            SizedBox(height: AppSpacing.sm),
            if (state.menu.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                child: Text(
                  "Aucun article actif dans ton menu. Ajoute des articles dans l'onglet Menu.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.mute),
                ),
              )
            else
              ...state.menu.map(
                (item) => CounterMenuItemRow(
                  item: item,
                  quantity: state.quantities[item.id] ?? 0,
                  enabled: !state.isSubmitting,
                  onIncrement: () => cubit.increment(item.id),
                  onDecrement: () => cubit.decrement(item.id),
                ),
              ),
          ],
        ),
        bottomNavigationBar: _CheckoutBar(state: state, pinCtrl: _pinCtrl),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.state, required this.pinCtrl});

  final CounterReady state;
  final TextEditingController pinCtrl;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomPad + keyboard,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: AppShadows.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.isEmpty
                    ? 'Aucun article'
                    : '${state.itemCount} article${state.itemCount > 1 ? 's' : ''}',
                style: AppTextStyles.body.copyWith(color: AppColors.mute),
              ),
              Text(
                '${formatXof(state.total)} FCFA',
                style: AppTextStyles.h2.copyWith(
                  color: state.exceedsSpendable
                      ? AppColors.dangerText
                      : AppColors.ink,
                ),
              ),
            ],
          ),
          if (state.exceedsSpendable) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              "Le total dépasse ce que l'élève peut dépenser aujourd'hui "
              '(${formatXof(state.preview.spendableToday)} FCFA).',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.dangerText,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.sm),
          CounterPinField(controller: pinCtrl, enabled: !state.isSubmitting),
          SizedBox(height: AppSpacing.sm),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: pinCtrl,
            builder: (ctx, pin, _) => AppButton.primary(
              label: state.isEmpty
                  ? 'Encaisser'
                  : 'Encaisser ${formatXof(state.total)} FCFA',
              isLoading: state.isSubmitting,
              onPressed: state.canPay && pin.text.length == counterPinLength
                  ? () => ctx.read<CounterCubit>().pay(pin.text)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
