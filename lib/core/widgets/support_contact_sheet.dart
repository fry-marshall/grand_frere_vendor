import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/support_contact.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SupportContactSheet extends StatelessWidget {
  const SupportContactSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.r20),
      ),
      builder: (_) => const SupportContactSheet(),
    );
  }

  Future<void> _open(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (launched) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir l\'application.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            Text(
              'Contacter le support',
              textAlign: TextAlign.center,
              style: AppTextStyles.h2.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              SupportContact.displayPhone,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.mute),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ContactOption(
              icon: Icons.chat_rounded,
              label: 'Écrire sur WhatsApp',
              onTap: () => _open(context, SupportContact.whatsAppUri),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ContactOption(
              icon: Icons.call_rounded,
              label: 'Appeler',
              onTap: () => _open(context, SupportContact.callUri),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.md,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.cardVertical,
        ),
        decoration: BoxDecoration(
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.maroon),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.brownSoft),
          ],
        ),
      ),
    );
  }
}
