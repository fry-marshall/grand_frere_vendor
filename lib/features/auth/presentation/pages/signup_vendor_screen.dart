import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/school.dart';
import '../bloc/signup_vendor_bloc/signup_vendor_bloc.dart';
import '../bloc/signup_vendor_bloc/signup_vendor_event.dart';
import '../bloc/signup_vendor_bloc/signup_vendor_state.dart';
import 'signup_form_step.dart';
import 'signup_school_step.dart';

class SignupVendorScreen extends StatelessWidget {
  const SignupVendorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<SignupVendorBloc>()
        ..add(const SignupVendorLoadSchools()),
      child: const _SignupFlow(),
    );
  }
}

class _SignupFlow extends StatefulWidget {
  const _SignupFlow();

  @override
  State<_SignupFlow> createState() => _SignupFlowState();
}

class _SignupFlowState extends State<_SignupFlow> {
  int _step = 0;
  School? _selectedSchool;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _shopNameCtrl = TextEditingController();
  final _waveCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _shopNameCtrl,
      _waveCtrl,
      _phoneCtrl,
      _passwordCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final school = _selectedSchool;
    if (school == null) return;

    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final shopName = _shopNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;
    final wave = _waveCtrl.text.trim();

    if ([firstName, lastName, shopName, phone, password].any((v) => v.isEmpty)) {
      AppToast.show(
        context,
        'Veuillez remplir tous les champs obligatoires.',
        isError: true,
      );
      return;
    }

    context.read<SignupVendorBloc>().add(
          SignupVendorSubmitRequested(
            firstName: firstName,
            lastName: lastName,
            phone: phone.startsWith('+225') ? phone : '+225$phone',
            password: password,
            shopName: shopName,
            schoolId: school.id,
            waveNumber: wave.isEmpty ? null : wave,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step = 0);
      },
      child: BlocListener<SignupVendorBloc, SignupVendorState>(
        listener: (context, state) {
          if (state is SignupVendorSuccess) {
            context.go(Routes.pending);
          } else if (state is SignupVendorError) {
            AppToast.show(context, state.message, isError: true);
          }
        },
        child: _step == 0
            ? SignupSchoolStep(
                selectedSchool: _selectedSchool,
                onSchoolSelected: (s) => setState(() => _selectedSchool = s),
                onNext: () => setState(() => _step = 1),
              )
            : SignupFormStep(
                selectedSchool: _selectedSchool!,
                firstNameCtrl: _firstNameCtrl,
                lastNameCtrl: _lastNameCtrl,
                shopNameCtrl: _shopNameCtrl,
                waveCtrl: _waveCtrl,
                phoneCtrl: _phoneCtrl,
                passwordCtrl: _passwordCtrl,
                onBack: () => setState(() => _step = 0),
                onSubmit: _submit,
              ),
      ),
    );
  }
}
