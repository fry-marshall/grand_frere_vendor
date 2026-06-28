import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/cashin_cubit.dart';
import '../cubit/cashin_state.dart';

class CashinCodeView extends StatefulWidget {
  const CashinCodeView({
    super.key,
    required this.onBack,
    required this.onSwitchToScan,
  });

  final VoidCallback onBack;
  final VoidCallback onSwitchToScan;

  @override
  State<CashinCodeView> createState() => _CashinCodeViewState();
}

class _CashinCodeViewState extends State<CashinCodeView> {
  final List<int?> _digits = [null, null, null, null];

  bool get _isComplete => _digits.every((d) => d != null);

  void _onDigit(int digit) {
    final idx = _digits.indexOf(null);
    if (idx == -1) return;
    setState(() => _digits[idx] = digit);
  }

  void _onBackspace() {
    for (var i = 3; i >= 0; i--) {
      if (_digits[i] != null) {
        setState(() => _digits[i] = null);
        return;
      }
    }
  }

  void _onValidate() {
    if (!_isComplete) return;
    final code = _digits.map((d) => d.toString()).join();
    context.read<CashinCubit>().lookupByCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CashinCubit, CashinState>(
      listenWhen: (_, s) => s is CashinError,
      listener: (ctx, state) => setState(() => _digits.fillRange(0, 4, null)),
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
            onPressed: widget.onBack,
          ),
          title: Text(
            'Saisir le n° de commande',
            style: AppTextStyles.h3.copyWith(color: AppColors.maroon),
          ),
          actions: [
            TextButton.icon(
              onPressed: widget.onSwitchToScan,
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.gold,
                size: 18,
              ),
              label: Text(
                'Scan',
                style: AppTextStyles.buttonSmall.copyWith(color: AppColors.gold),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  Text(
                    "Demande le numéro affiché sur l'écran de l'élève",
                    style: AppTextStyles.body.copyWith(color: AppColors.mute),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _CodeDisplay(digits: _digits),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Format : 4 chiffres',
                    style: AppTextStyles.caption.copyWith(color: AppColors.mute),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _Numpad(onDigit: _onDigit, onBackspace: _onBackspace),
            ),
            BlocBuilder<CashinCubit, CashinState>(
              builder: (ctx, state) {
                final isLoading = state is CashinLoading;
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  child: GestureDetector(
                    onTap: (_isComplete && !isLoading) ? _onValidate : null,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
                      decoration: BoxDecoration(
                        gradient: _isComplete
                            ? const LinearGradient(
                                colors: [AppColors.gold, AppColors.goldDeep],
                              )
                            : null,
                        color: _isComplete ? null : AppColors.goldSoft,
                        borderRadius: AppRadius.pill,
                      ),
                      alignment: Alignment.center,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Valider',
                              style: AppTextStyles.buttonLabel.copyWith(
                                color: _isComplete ? Colors.white : AppColors.gold,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeDisplay extends StatelessWidget {
  const _CodeDisplay({required this.digits});
  final List<int?> digits;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('#', style: AppTextStyles.h1.copyWith(color: AppColors.maroon)),
        SizedBox(width: AppSpacing.sm),
        ...List.generate(
          4,
          (i) => _DigitBox(digit: digits[i]),
        ),
      ],
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({required this.digit});
  final int? digit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 68,
      margin: EdgeInsets.only(right: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.input,
        boxShadow: AppShadows.sm,
      ),
      alignment: Alignment.center,
      child: digit != null
          ? Text(digit.toString(), style: AppTextStyles.h1.copyWith(color: AppColors.maroon))
          : null,
    );
  }
}

class _Numpad extends StatelessWidget {
  const _Numpad({required this.onDigit, required this.onBackspace});
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NumRow(digits: const [1, 2, 3], onDigit: onDigit),
          SizedBox(height: AppSpacing.xs),
          _NumRow(digits: const [4, 5, 6], onDigit: onDigit),
          SizedBox(height: AppSpacing.xs),
          _NumRow(digits: const [7, 8, 9], onDigit: onDigit),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Expanded(child: _NumKey(digit: 0, onDigit: onDigit)),
              Expanded(child: _BackspaceKey(onBackspace: onBackspace)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumRow extends StatelessWidget {
  const _NumRow({required this.digits, required this.onDigit});
  final List<int> digits;
  final ValueChanged<int> onDigit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: digits
          .map((d) => Expanded(child: _NumKey(digit: d, onDigit: onDigit)))
          .toList(),
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({required this.digit, required this.onDigit});
  final int digit;
  final ValueChanged<int> onDigit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onDigit(digit),
      child: Container(
        margin: EdgeInsets.all(AppSpacing.micro),
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.xs,
        ),
        alignment: Alignment.center,
        child: Text(
          digit.toString(),
          style: AppTextStyles.h2.copyWith(color: AppColors.maroon),
        ),
      ),
    );
  }
}

class _BackspaceKey extends StatelessWidget {
  const _BackspaceKey({required this.onBackspace});
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBackspace,
      child: Container(
        margin: EdgeInsets.all(AppSpacing.micro),
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.xs,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.backspace_outlined, color: AppColors.maroon, size: 22),
      ),
    );
  }
}
