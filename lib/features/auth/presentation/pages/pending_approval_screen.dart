import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_bloc/auth_bloc.dart';
import '../../../../core/auth/auth_bloc/auth_event.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                size: 72,
                color: AppColors.gold,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Compte en attente',
                style: AppTextStyles.h1.copyWith(color: AppColors.maroon),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Votre compte vendeur a bien été créé.\nL\'équipe Grand Frère va examiner votre dossier et vous notifier dès l\'approbation.',
                style: AppTextStyles.body.copyWith(color: AppColors.mute),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.brown),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Délai habituel : 24 à 48 heures ouvrées.',
                        style: AppTextStyles.cardBody
                            .copyWith(color: AppColors.brown),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.outlined(
                label: 'J\'ai déjà un compte approuvé',
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                  context.go(Routes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
