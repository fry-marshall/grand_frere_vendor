import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/legal_links.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TermsConsentText extends StatefulWidget {
  const TermsConsentText({super.key, required this.action});

  final String action;

  @override
  State<TermsConsentText> createState() => _TermsConsentTextState();
}

class _TermsConsentTextState extends State<TermsConsentText> {
  late final _termsTap = TapGestureRecognizer()
    ..onTap = () => launchUrl(
          LegalLinks.termsUri,
          mode: LaunchMode.externalApplication,
        );

  @override
  void dispose() {
    _termsTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.caption.copyWith(
      color: AppColors.mute,
      height: 1.5,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: '${widget.action}, vous acceptez les '),
          TextSpan(
            text: 'conditions d\'utilisation et la politique de confidentialité',
            style: base.copyWith(
              color: AppColors.maroon,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.maroon,
            ),
            recognizer: _termsTap,
          ),
          const TextSpan(text: ' de GRAND-FRÈRE.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
