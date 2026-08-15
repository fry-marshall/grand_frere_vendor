import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_toast.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import 'auth_bloc/auth_bloc.dart';
import 'auth_bloc/auth_event.dart';

/// Shared "delete my account" flow: confirmation dialog, API call, then a
/// clean local logout on success — used from both the Account screen and
/// the blocked-vendor screen, since a rejected/suspended vendor otherwise
/// has no other way out of the app.
Future<void> confirmAndDeleteAccount(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      title: Text(
        'Supprimer mon compte ?',
        style: AppTextStyles.h2.copyWith(color: AppColors.ink),
      ),
      content: Text(
        'Cette action est définitive : vous ne pourrez plus vous '
        'reconnecter avec ce compte.',
        style: AppTextStyles.body.copyWith(color: AppColors.mute),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'Annuler',
            style: AppTextStyles.body.copyWith(color: AppColors.mute),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Supprimer',
            style: AppTextStyles.body.copyWith(
              color: AppColors.dangerText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final result = await getIt<AuthRepository>().deleteAccount();
  if (!context.mounted) return;

  result.fold(
    (failure) => AppToast.show(context, failure.message, isError: true),
    (_) => getIt<AuthBloc>().add(const AuthLogoutRequested()),
  );
}
