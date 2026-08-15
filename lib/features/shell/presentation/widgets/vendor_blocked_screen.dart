import 'package:flutter/material.dart';

import '../../../../core/auth/auth_bloc/auth_bloc.dart';
import '../../../../core/auth/auth_bloc/auth_event.dart';
import '../../../../core/auth/delete_account.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Replaces the whole shell (no tabs, no FAB) when the vendor account is
/// REJECTED or SUSPENDED — unlike PENDING, there's nothing to prep while
/// waiting, so no action should be reachable at all.
class VendorBlockedScreen extends StatelessWidget {
  const VendorBlockedScreen({super.key, required this.rejected});

  /// `true` for REJECTED, `false` for SUSPENDED — only changes the copy.
  final bool rejected;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.lg + bottomPad,
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.block_rounded,
                        size: 56,
                        color: AppColors.dangerText,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        rejected ? 'Compte refusé' : 'Compte suspendu',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.maroon,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        rejected
                            ? "Votre demande d'inscription en tant que "
                                  "vendeur n'a pas été validée par l'équipe "
                                  'Grand Frère.'
                            : "Votre compte vendeur a été suspendu par "
                                  "l'équipe Grand Frère. Vous n'avez plus "
                                  "accès à l'application.",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.mute,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.warningSurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Pour toute question, contactez l'équipe Grand "
                          'Frère.',
                          style: AppTextStyles.cardBody.copyWith(
                            color: AppColors.brown,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _ActionButton(
                label: 'Supprimer mon compte',
                color: AppColors.dangerText,
                onTap: () => confirmAndDeleteAccount(context),
              ),
              SizedBox(height: AppSpacing.sm),
              _ActionButton(
                label: 'Se déconnecter',
                color: AppColors.mute,
                onTap: () => getIt<AuthBloc>().add(const AuthLogoutRequested()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.pill,
          border: Border.all(color: AppColors.line),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.buttonLabel.copyWith(color: color),
        ),
      ),
    );
  }
}
