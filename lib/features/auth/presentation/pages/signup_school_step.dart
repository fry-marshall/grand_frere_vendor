import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/school.dart';
import '../bloc/signup_vendor_bloc/signup_vendor_bloc.dart';
import '../bloc/signup_vendor_bloc/signup_vendor_state.dart';
import '../widgets/school_row_tile.dart';
import '../widgets/school_search_bar.dart';
import '../widgets/signup_chrome.dart';

class SignupSchoolStep extends StatefulWidget {
  const SignupSchoolStep({
    super.key,
    required this.selectedSchool,
    required this.onSchoolSelected,
    required this.onNext,
  });

  final School? selectedSchool;
  final ValueChanged<School> onSchoolSelected;
  final VoidCallback onNext;

  @override
  State<SignupSchoolStep> createState() => _SignupSchoolStepState();
}

class _SignupSchoolStepState extends State<SignupSchoolStep> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<School> _filter(List<School> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.sigle.toLowerCase().contains(q) ||
          s.address.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SignupNavBar(step: 1, onBack: () => Navigator.of(context).pop()),
            const SignupStepBars(filledCount: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Où se trouve votre stand ?',
                    style: AppTextStyles.h1.copyWith(
                        color: AppColors.maroon, fontSize: 25, height: 1.15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sélectionnez l\'école où vous proposez vos repas. Les élèves de cet établissement pourront commander chez vous.',
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.brown, fontSize: 13.5, height: 1.5),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 14),
              child: SchoolSearchBar(
                controller: _searchCtrl,
                onClear: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              ),
            ),
            Expanded(
              child: BlocBuilder<SignupVendorBloc, SignupVendorState>(
                builder: (context, state) {
                  if (state is SignupVendorLoadingSchools) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    );
                  }
                  final schools = switch (state) {
                    SignupVendorSchoolsLoaded(:final schools) => schools,
                    SignupVendorSubmitting(:final schools) => schools,
                    SignupVendorError(:final schools) => schools,
                    _ => <School>[],
                  };
                  final filtered = _filter(schools);
                  final hasQuery = _query.isNotEmpty;
                  final popular = filtered.where((s) => s.popular).toList();
                  final others = filtered.where((s) => !s.popular).toList();

                  return Stack(
                    children: [
                      ListView(
                        padding: EdgeInsets.fromLTRB(14, 0, 14, 130 + bottomPad),
                        children: [
                          if (filtered.isEmpty && hasQuery)
                            _EmptySearch(query: _query)
                          else ...[
                            // Popular section — only shown when not searching
                            if (popular.isNotEmpty && !hasQuery) ...[
                              _SectionHeader('Établissements populaires'),
                              ...popular.map(
                                (s) => SchoolRowTile(
                                  school: s,
                                  selected: widget.selectedSchool?.id == s.id,
                                  onTap: () => widget.onSchoolSelected(s),
                                ),
                              ),
                            ],
                            if (others.isNotEmpty) ...[
                              _SectionHeader(
                                hasQuery ? 'Résultats' : 'Toutes les écoles',
                                topPadding: popular.isNotEmpty && !hasQuery,
                              ),
                              ...others.map(
                                (s) => SchoolRowTile(
                                  school: s,
                                  selected: widget.selectedSchool?.id == s.id,
                                  onTap: () => widget.onSchoolSelected(s),
                                ),
                              ),
                            ],
                            // Fallback: no section split (all non-popular)
                            if (popular.isEmpty && others.isEmpty && !hasQuery)
                              _SectionHeader('Tous les établissements'),
                          ],
                        ],
                      ),
                      // Gradient CTA — HTML: position:absolute + linear-gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.28, 1.0],
                              colors: [
                                AppColors.paper.withAlpha(0),
                                AppColors.paper,
                                AppColors.paper,
                              ],
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(
                              20, 24, 20, 26 + bottomPad),
                          // HTML: opacity:.42 on gold button, not Material grey
                          child: IgnorePointer(
                            ignoring: widget.selectedSchool == null,
                            child: AnimatedOpacity(
                              opacity:
                                  widget.selectedSchool != null ? 1.0 : 0.42,
                              duration: const Duration(milliseconds: 150),
                              child: AppButton.primary(
                                label: widget.selectedSchool != null
                                    ? 'Continuer avec ${_clip(widget.selectedSchool!.name)}'
                                    : 'Sélectionner une école',
                                onPressed: widget.onNext,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _clip(String s) =>
      s.length > 22 ? '${s.substring(0, 22)}…' : s;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text, {this.topPadding = false});

  final String text;
  final bool topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, topPadding ? 14 : 4, 8, 6),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.body.copyWith(
          color: AppColors.brown,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.88,
          height: 1.0,
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Text(
        'Aucune école trouvée pour « $query ».',
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(color: AppColors.mute),
      ),
    );
  }
}
