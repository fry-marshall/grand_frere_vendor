import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/balance_cubit.dart';
import '../cubit/balance_state.dart';

class WithdrawalFormSheet extends StatefulWidget {
  const WithdrawalFormSheet({super.key, this.prefillWaveNumber});
  final String? prefillWaveNumber;

  static Future<void> show(BuildContext context, {String? waveNumber}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<BalanceCubit>(),
        child: WithdrawalFormSheet(prefillWaveNumber: waveNumber),
      ),
    );
  }

  @override
  State<WithdrawalFormSheet> createState() => _WithdrawalFormSheetState();
}

class _WithdrawalFormSheetState extends State<WithdrawalFormSheet> {
  late final TextEditingController _amount;
  late final TextEditingController _wave;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
    _wave = TextEditingController(text: widget.prefillWaveNumber ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _wave.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<BalanceCubit>().createWithdrawal(
          amount: int.parse(_amount.text.trim()),
          waveNumber: _wave.text.trim(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return BlocListener<BalanceCubit, BalanceState>(
      listener: (_, state) {
        if ((state is BalanceLoaded && !state.isCreating) ||
            state is BalanceActionError) {
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md + bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Demander un retrait',
                style: AppTextStyles.h2.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: AppSpacing.micro),
              Text(
                'Le montant sera transféré sur votre numéro Wave.',
                style: AppTextStyles.body.copyWith(color: AppColors.mute),
              ),
              SizedBox(height: AppSpacing.lg),
              _Field(
                controller: _amount,
                label: 'Montant (FCFA)',
                hint: '10 000',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 100) return 'Minimum 100 FCFA';
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.sm),
              _Field(
                controller: _wave,
                label: 'Numéro Wave',
                hint: '+2250700000000',
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().length < 3) return 'Numéro invalide';
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg),
              BlocBuilder<BalanceCubit, BalanceState>(
                builder: (_, state) {
                  final isCreating =
                      state is BalanceLoaded && state.isCreating;
                  return GestureDetector(
                    onTap: isCreating ? null : _submit,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.buttonVertical,
                      ),
                      decoration: BoxDecoration(
                        gradient: isCreating
                            ? null
                            : const LinearGradient(
                                colors: [AppColors.gold, AppColors.goldDeep],
                              ),
                        color: isCreating ? AppColors.line : null,
                        borderRadius: AppRadius.pill,
                        boxShadow: isCreating ? null : AppShadows.md,
                      ),
                      alignment: Alignment.center,
                      child: isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.gold,
                              ),
                            )
                          : Text(
                              'Confirmer le retrait',
                              style: AppTextStyles.buttonLabel
                                  .copyWith(color: Colors.white),
                            ),
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: AppColors.ink)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTextStyles.body.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.mute),
            filled: true,
            fillColor: AppColors.paper,
            border: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.dangerText),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.inputVertical,
            ),
          ),
        ),
      ],
    );
  }
}
