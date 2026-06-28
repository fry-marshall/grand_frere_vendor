import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/reset_password_bloc/reset_password_bloc.dart';
import '../bloc/reset_password_bloc/reset_password_event.dart';
import '../bloc/reset_password_bloc/reset_password_state.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({
    super.key,
    required this.phone,
    required this.code,
  });

  final String phone;
  final String code;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ResetPasswordBloc>(),
      child: _ResetPasswordView(phone: phone, code: code),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView({required this.phone, required this.code});

  final String phone;
  final String code;

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // In dev: pre-fill the OTP received from the API
    if (widget.code.isNotEmpty) _codeCtrl.text = widget.code;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _codeCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (code.isEmpty || password.isEmpty || confirm.isEmpty) return;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    context.read<ResetPasswordBloc>().add(
          ResetPasswordSubmitRequested(
            phone: widget.phone,
            code: code,
            newPassword: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetPasswordBloc, ResetPasswordState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mot de passe modifié avec succès !'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(Routes.login);
        } else if (state is ResetPasswordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.paper,
        appBar: AppBar(
          backgroundColor: AppColors.paper,
          leading: BackButton(
            onPressed: () => context.pop(),
            color: AppColors.maroon,
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
            builder: (context, state) {
              final loading = state is ResetPasswordLoading;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Nouveau mot de passe',
                      style: AppTextStyles.h1.copyWith(color: AppColors.ink),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Entrez le code reçu par SMS et votre nouveau mot de passe.',
                      style:
                          AppTextStyles.body.copyWith(color: AppColors.mute),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      label: 'Code OTP',
                      controller: _codeCtrl,
                      placeholder: '482910',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Nouveau mot de passe',
                      controller: _passwordCtrl,
                      obscureText: true,
                      placeholder: 'Minimum 8 caractères',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Confirmer le mot de passe',
                      controller: _confirmCtrl,
                      obscureText: true,
                      placeholder: '••••••••',
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton.primary(
                      label: 'Réinitialiser',
                      onPressed: _submit,
                      isLoading: loading,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
