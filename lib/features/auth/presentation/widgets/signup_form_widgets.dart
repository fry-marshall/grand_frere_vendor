import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/school.dart';
import 'school_icon.dart';

class SignupSectionLabel extends StatelessWidget {
  const SignupSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.label
            .copyWith(color: AppColors.brown, fontSize: 11, letterSpacing: 1.4),
      ),
    );
  }
}

class SignupSelectedSchool extends StatelessWidget {
  const SignupSelectedSchool({super.key, required this.school});

  final School school;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const SchoolIcon(),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre école',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.mute, fontSize: 11, letterSpacing: 1.0),
                ),
                const SizedBox(height: 2),
                Text(
                  school.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.maroon,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WaveTextField extends StatefulWidget {
  const WaveTextField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<WaveTextField> createState() => _WaveTextFieldState();
}

class _WaveTextFieldState extends State<WaveTextField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéro Wave',
          style: AppTextStyles.body.copyWith(
              color: AppColors.maroon,
              fontWeight: FontWeight.w700,
              fontSize: 13),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            // No border at rest — only gold ring on focus
            border: _focused
                ? Border.all(color: AppColors.gold, width: 1.5)
                : null,
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(51),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.ink.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              _WaveBadge(),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.ink, fontSize: 15),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '07 00 00 00 00',
                    hintStyle: AppTextStyles.body
                        .copyWith(color: AppColors.mute, fontSize: 15),
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Votre solde sera reversé chaque soir sur ce compte',
          style: AppTextStyles.caption.copyWith(color: AppColors.mute),
        ),
      ],
    );
  }
}

class _WaveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2EBA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.waves_rounded, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            'WAVE',
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class SignupFormCta extends StatelessWidget {
  const SignupFormCta({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: const Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [
          BoxShadow(
            color: AppColors.paper.withAlpha(242),
            blurRadius: 22,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        14,
        AppSpacing.lg,
        14 + MediaQuery.paddingOf(context).bottom,
      ),
      child: child,
    );
  }
}
