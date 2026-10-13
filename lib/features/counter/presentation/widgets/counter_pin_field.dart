import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

const counterPinLength = 4;

class CounterPinField extends StatelessWidget {
  const CounterPinField({
    super.key,
    required this.controller,
    required this.enabled,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: AppRadius.sm,
      borderSide: const BorderSide(color: AppColors.line),
    );
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: true,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: counterPinLength,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: AppTextStyles.h2.copyWith(color: AppColors.ink, letterSpacing: 12),
      decoration: InputDecoration(
        counterText: '',
        hintText: '••••',
        hintStyle: AppTextStyles.h2.copyWith(
          color: AppColors.line,
          letterSpacing: 12,
        ),
        labelText: "PIN de l'élève",
        filled: true,
        fillColor: AppColors.paper,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: AppSpacing.inputVertical,
        ),
      ),
    );
  }
}
