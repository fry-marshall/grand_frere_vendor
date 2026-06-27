import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum _AppButtonVariant { secondary, primary, outlined }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.secondary;

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  }) : _variant = _AppButtonVariant.outlined;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final _AppButtonVariant _variant;

  static const _shape = RoundedRectangleBorder(borderRadius: AppRadius.pill);
  static const _padding =
      EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical);

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    if (_variant == _AppButtonVariant.outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.maroon,
            side: const BorderSide(color: AppColors.maroon, width: 2),
            padding: _padding,
            shape: _shape,
          ),
          child: _label(AppColors.maroon),
        ),
      );
    }

    final bg = _variant == _AppButtonVariant.primary
        ? AppColors.gold
        : AppColors.maroon;

    // GfBtn primary: boxShadow '0 4px 14px rgba(91,30,15,.18)'
    final shadow = _variant == _AppButtonVariant.primary
        ? [
            BoxShadow(
              color: AppColors.maroon.withAlpha(46),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ]
        : null;

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.pill,
          boxShadow: shadow,
        ),
        child: FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            padding: _padding,
            shape: _shape,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : _label(Colors.white),
        ),
      ),
    );
  }

  Widget _label(Color color) => Text(
        label,
        style: AppTextStyles.buttonLabel.copyWith(color: color),
      );
}
