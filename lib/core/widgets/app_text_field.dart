import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.helperText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixText,
    this.autofocus = false,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? placeholder;
  final String? helperText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? prefixText;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _effectiveFocus;
  bool _focused = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _effectiveFocus = widget.focusNode ?? FocusNode();
    _effectiveFocus.addListener(
      () => setState(() => _focused = _effectiveFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _effectiveFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          // GfInput label: fontWeight 700, fontSize 13, color maroon
          style: AppTextStyles.body.copyWith(
            color: AppColors.maroon,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: AppRadius.input,
            border: Border.all(
              color: _focused ? AppColors.gold : AppColors.line,
              width: 1.5,
            ),
            // GfInput: box-shadow 0 0 0 3px rgba(232,181,74,.2) on focus
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(51),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscureText && _obscure,
            keyboardType: widget.keyboardType,
            autofocus: widget.autofocus,
            focusNode: _effectiveFocus,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            style: AppTextStyles.body
                .copyWith(color: AppColors.ink, fontSize: 15, height: 1.0),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: AppTextStyles.body.copyWith(
                color: AppColors.mute,
                fontSize: 15,
                height: 1.0,
              ),
              prefixText: widget.prefixText,
              prefixStyle: AppTextStyles.body.copyWith(
                color: AppColors.mute,
                fontSize: 15,
              ),
              suffixIcon: widget.obscureText
                  ? TextButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.mute,
                        padding: const EdgeInsets.only(right: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _obscure ? 'Voir' : 'Masquer',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mute,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ),
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              widget.helperText!,
              style: AppTextStyles.caption.copyWith(color: AppColors.mute),
            ),
          ),
      ],
    );
  }
}
