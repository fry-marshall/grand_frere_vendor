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
import '../bloc/forgot_password_bloc/forgot_password_bloc.dart';
import '../bloc/forgot_password_bloc/forgot_password_event.dart';
import '../bloc/forgot_password_bloc/forgot_password_state.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ForgotPasswordBloc>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;
    context.read<ForgotPasswordBloc>().add(
          ForgotPasswordSubmitRequested(
            phone: phone.startsWith('+225') ? phone : '+225$phone',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordBloc, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordOtpReceived) {
          context.push(
            Routes.resetPassword,
            extra: (phone: state.phone, code: state.code ?? ''),
          );
        } else if (state is ForgotPasswordError) {
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
          child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
            builder: (context, state) {
              final loading = state is ForgotPasswordLoading;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Mot de passe oublié',
                      style: AppTextStyles.h1.copyWith(color: AppColors.ink),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Entrez votre numéro de téléphone. Vous recevrez un code par SMS.',
                      style:
                          AppTextStyles.body.copyWith(color: AppColors.mute),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      label: 'Téléphone',
                      controller: _phoneCtrl,
                      placeholder: '07 XX XX XX XX',
                      prefixText: '+225 ',
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton.primary(
                      label: 'Envoyer le code',
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
