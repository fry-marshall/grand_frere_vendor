import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_bloc/auth_bloc.dart';
import '../../../../core/auth/auth_bloc/auth_event.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/login_bloc/login_bloc.dart';
import '../bloc/login_bloc/login_event.dart';
import '../bloc/login_bloc/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (phone.isEmpty || password.isEmpty) return;
    context.read<LoginBloc>().add(
          LoginSubmitRequested(
            phone: phone.startsWith('+225') ? phone : '+225$phone',
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.read<AuthBloc>().add(
                AuthLoginRequested(
                  accessToken: state.tokens.accessToken,
                  refreshToken: state.tokens.refreshToken,
                ),
              );
        } else if (state is LoginError) {
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
        body: SafeArea(
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              final loading = state is LoginLoading;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Image.asset('assets/logo.png', width: 72, height: 72),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Connexion',
                      style: AppTextStyles.h1.copyWith(color: AppColors.ink),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Accédez à votre espace vendeur.',
                      style: AppTextStyles.body.copyWith(color: AppColors.mute),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      label: 'Téléphone',
                      controller: _phoneCtrl,
                      placeholder: '07 XX XX XX XX',
                      prefixText: '+225 ',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Mot de passe',
                      controller: _passwordCtrl,
                      obscureText: true,
                      placeholder: '••••••••',
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(Routes.forgot),
                        child: Text(
                          'Mot de passe oublié ?',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.brown,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton.primary(
                      label: 'Se connecter',
                      onPressed: _submit,
                      isLoading: loading,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pas encore de compte ? ',
                          style:
                              AppTextStyles.body.copyWith(color: AppColors.mute),
                        ),
                        GestureDetector(
                          onTap: () => context.push(Routes.signup),
                          child: Text(
                            'S\'inscrire',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.maroon,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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
