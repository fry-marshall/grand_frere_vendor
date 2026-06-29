import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/vendor.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../cubit/account_cubit.dart';
import '../cubit/account_state.dart';
import '../cubit/vendor_cubit.dart';
import '../cubit/vendor_state.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountCubit>(
      create: (_) => AccountCubit(
        getIt<VendorRepository>(),
        getIt<AuthRepository>(),
        getIt<VendorCubit>(),
      ),
      child: const _AccountBody(),
    );
  }
}

class _AccountBody extends StatelessWidget {
  const _AccountBody();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listener: (ctx, state) {
        if (state is AccountError) {
          AppToast.show(ctx, state.message, isError: true);
          ctx.read<AccountCubit>().reset();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: BlocBuilder<VendorCubit, VendorState>(
            builder: (ctx, vs) {
              final vendor = vs is VendorLoaded ? vs.vendor : null;
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                children: [
                  _ProfileHeader(vendor: vendor),
                  SizedBox(height: AppSpacing.xl),
                  _SectionTitle('Mon profil'),
                  SizedBox(height: AppSpacing.xs),
                  _InfoTile(
                    icon: Icons.storefront_outlined,
                    label: 'Boutique',
                    value: vendor?.shopName ?? '—',
                  ),
                  _InfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Téléphone',
                    value: vendor?.phone ?? '—',
                  ),
                  _InfoTile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Numéro Wave',
                    value: vendor?.waveNumber ?? 'Non renseigné',
                  ),
                  _InfoTile(
                    icon: Icons.schedule_outlined,
                    label: 'Horaires',
                    value: (vendor?.openingTime != null &&
                            vendor?.closingTime != null)
                        ? '${vendor!.openingTime} – ${vendor.closingTime}'
                        : 'Non renseignées',
                  ),
                  SizedBox(height: AppSpacing.xs),
                  if (vendor != null)
                    _ActionTile(
                      icon: Icons.edit_outlined,
                      label: 'Modifier le profil',
                      color: AppColors.violet,
                      onTap: () => _EditProfileSheet.show(ctx, vendor),
                    ),
                  SizedBox(height: AppSpacing.lg),
                  _SectionTitle('Sécurité'),
                  SizedBox(height: AppSpacing.xs),
                  _ActionTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Changer le mot de passe',
                    color: AppColors.maroon,
                    onTap: () => _ChangePasswordSheet.show(ctx),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  _SectionTitle('Session'),
                  SizedBox(height: AppSpacing.xs),
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Se déconnecter',
                    color: AppColors.dangerText,
                    onTap: () => ctx.read<VendorCubit>().reset(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({this.vendor});
  final Vendor? vendor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.gold, AppColors.carrot],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: AppShadows.md,
          ),
          child: Center(
            child: Text(
              vendor?.initials ?? '?',
              style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 22),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vendor?.fullName ?? '',
                style: AppTextStyles.h2.copyWith(color: AppColors.ink),
              ),
              Text(
                vendor?.shopName ?? '',
                style: AppTextStyles.body.copyWith(color: AppColors.mute),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: AppColors.mute,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.micro),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.sm,
        boxShadow: AppShadows.xs,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mute, size: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.caption.copyWith(color: AppColors.mute)),
                Text(value,
                    style: AppTextStyles.body.copyWith(color: AppColors.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.sm,
          boxShadow: AppShadows.xs,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTextStyles.body.copyWith(color: color)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.line, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Edit Profile Sheet ────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.vendor});
  final Vendor vendor;

  static Future<void> show(BuildContext context, Vendor vendor) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AccountCubit>()),
          BlocProvider.value(value: context.read<VendorCubit>()),
        ],
        child: _EditProfileSheet(vendor: vendor),
      ),
    );
  }

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _shopName;
  late final TextEditingController _wave;
  late final TextEditingController _opening;
  late final TextEditingController _closing;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _shopName = TextEditingController(text: widget.vendor.shopName);
    _wave = TextEditingController(text: widget.vendor.waveNumber ?? '');
    _opening = TextEditingController(text: widget.vendor.openingTime ?? '');
    _closing = TextEditingController(text: widget.vendor.closingTime ?? '');
  }

  @override
  void dispose() {
    _shopName.dispose();
    _wave.dispose();
    _opening.dispose();
    _closing.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final v = widget.vendor;
    await context.read<AccountCubit>().updateProfile(
          v.id,
          shopName:
              _shopName.text.trim() != v.shopName ? _shopName.text.trim() : null,
          waveNumber:
              _wave.text.trim().isNotEmpty ? _wave.text.trim() : null,
          openingTime:
              _opening.text.trim().isNotEmpty ? _opening.text.trim() : null,
          closingTime:
              _closing.text.trim().isNotEmpty ? _closing.text.trim() : null,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return BlocListener<AccountCubit, AccountState>(
      listener: (_, state) {
        if ((state is AccountSuccess || state is AccountError) && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: _SheetScaffold(
        title: 'Modifier le profil',
        bottom: bottom,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _SheetField(
                controller: _shopName,
                label: 'Nom de la boutique',
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Min. 2 caractères' : null,
              ),
              SizedBox(height: AppSpacing.sm),
              _SheetField(
                controller: _wave,
                label: 'Numéro Wave',
                hint: '+2250700000000',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _SheetField(
                      controller: _opening,
                      label: 'Ouverture',
                      hint: '08:00',
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _SheetField(
                      controller: _closing,
                      label: 'Fermeture',
                      hint: '17:00',
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),
              BlocBuilder<AccountCubit, AccountState>(
                builder: (_, state) => _SubmitButton(
                  label: 'Enregistrer',
                  isSaving: state is AccountSaving,
                  onTap: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Change Password Sheet ─────────────────────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AccountCubit>(),
        child: const _ChangePasswordSheet(),
      ),
    );
  }

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _current = TextEditingController();
  final _newPw = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _current.dispose();
    _newPw.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<AccountCubit>().changePassword(
          currentPassword: _current.text,
          newPassword: _newPw.text,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return BlocListener<AccountCubit, AccountState>(
      listener: (_, state) {
        if ((state is AccountSuccess || state is AccountError) && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: _SheetScaffold(
        title: 'Changer le mot de passe',
        bottom: bottom,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _SheetField(
                controller: _current,
                label: 'Mot de passe actuel',
                obscureText: _obscureCurrent,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.mute,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
              SizedBox(height: AppSpacing.sm),
              _SheetField(
                controller: _newPw,
                label: 'Nouveau mot de passe',
                obscureText: _obscureNew,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.mute,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Min. 8 caractères' : null,
              ),
              SizedBox(height: AppSpacing.sm),
              _SheetField(
                controller: _confirm,
                label: 'Confirmer le nouveau mot de passe',
                obscureText: true,
                validator: (v) => v != _newPw.text
                    ? 'Les mots de passe ne correspondent pas'
                    : null,
              ),
              SizedBox(height: AppSpacing.lg),
              BlocBuilder<AccountCubit, AccountState>(
                builder: (_, state) => _SubmitButton(
                  label: 'Confirmer',
                  isSaving: state is AccountSaving,
                  onTap: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared sheet components ───────────────────────────────────────────────────

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.title,
    required this.bottom,
    required this.child,
  });
  final String title;
  final double bottom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: AppRadius.pill,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.h2.copyWith(color: AppColors.ink)),
          SizedBox(height: AppSpacing.lg),
          child,
          SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: AppColors.ink)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: AppTextStyles.body.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.mute),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.paper,
            border: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: const BorderSide(color: AppColors.dangerText),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.inputVertical,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.isSaving,
    required this.onTap,
  });
  final String label;
  final bool isSaving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.buttonVertical),
        decoration: BoxDecoration(
          gradient: isSaving
              ? null
              : const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldDeep],
                ),
          color: isSaving ? AppColors.line : null,
          borderRadius: AppRadius.pill,
          boxShadow: isSaving ? null : AppShadows.md,
        ),
        alignment: Alignment.center,
        child: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gold,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.buttonLabel.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
