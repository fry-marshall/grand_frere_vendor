import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/school.dart';
import '../bloc/signup_vendor_bloc/signup_vendor_bloc.dart';
import '../bloc/signup_vendor_bloc/signup_vendor_state.dart';
import '../widgets/signup_chrome.dart';
import '../widgets/signup_form_widgets.dart';

class SignupFormStep extends StatelessWidget {
  const SignupFormStep({
    super.key,
    required this.selectedSchool,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.shopNameCtrl,
    required this.waveCtrl,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.onBack,
    required this.onSubmit,
  });

  final School selectedSchool;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController shopNameCtrl;
  final TextEditingController waveCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passwordCtrl;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SignupNavBar(step: 2, onBack: onBack),
            const SignupStepBars(filledCount: 2),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SignupSelectedSchool(school: selectedSchool),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Créons votre stand',
                      style: AppTextStyles.h1.copyWith(
                          color: AppColors.maroon,
                          fontSize: 23,
                          height: 1.15),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ces informations apparaîtront sur votre profil vendeur et permettent aux élèves de vous payer en toute sécurité.',
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.brown,
                          fontSize: 13,
                          height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SignupSectionLabel('Identité'),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Prénom',
                            controller: firstNameCtrl,
                            placeholder: 'ex : Aya',
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppTextField(
                            label: 'Nom',
                            controller: lastNameCtrl,
                            placeholder: 'ex : Tchep',
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      label: 'Nom du stand',
                      controller: shopNameCtrl,
                      placeholder: 'ex : Maquis Chez Aya',
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SignupSectionLabel('Paiement'),
                    WaveTextField(controller: waveCtrl),
                    const SizedBox(height: AppSpacing.sm),
                    AppTextField(
                      label: 'Numéro de téléphone',
                      controller: phoneCtrl,
                      placeholder: '07 00 00 00 00',
                      prefixText: '+225 ',
                      keyboardType: TextInputType.phone,
                      helperText: 'Pour les notifications de commande',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SignupSectionLabel('Sécurité'),
                    AppTextField(
                      label: 'Mot de passe',
                      controller: passwordCtrl,
                      obscureText: true,
                      placeholder: '••••••••',
                      helperText: 'Minimum 8 caractères',
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.mute,
                            fontSize: 11.5,
                            height: 1.5),
                        children: [
                          const TextSpan(
                              text: 'En continuant, vous acceptez les '),
                          TextSpan(
                            text: 'conditions vendeur',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.maroon,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(
                              text:
                                  ' de GRAND-FRÈRE et confirmez que les informations fournies sont exactes.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<SignupVendorBloc, SignupVendorState>(
        builder: (context, state) {
          final loading = state is SignupVendorSubmitting;
          return SignupFormCta(
            child: AppButton.primary(
              label: 'Créer mon stand',
              onPressed: loading ? null : onSubmit,
              isLoading: loading,
            ),
          );
        },
      ),
    );
  }
}
