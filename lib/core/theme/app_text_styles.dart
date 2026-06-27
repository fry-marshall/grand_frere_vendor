import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  // --- Display: Cinzel Decorative (wordmark / brand) ---
  static final display = GoogleFonts.cinzelDecorative(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.72,
  );

  // --- Headings: Fraunces (serif) ---
  static final h1 = GoogleFonts.fraunces(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.28,
  );

  static final h2 = GoogleFonts.fraunces(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static final cardHeading = GoogleFonts.fraunces(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static final cardBalance = GoogleFonts.fraunces(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  // --- UI: Nunito (sans-serif) ---
  static final h3 = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static final buttonLabel = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.16,
  );

  static final buttonSmall = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static final body = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static final cardTitle = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static final cardBody = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static final caption = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static final label = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
  );

  static final tabActive = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w800,
  );

  static final tabInactive = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  // --- Technical: JetBrains Mono ---
  static final mono = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static final monoSmall = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.6,
  );
}
