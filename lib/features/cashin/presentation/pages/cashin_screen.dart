import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_toast.dart';
import '../cubit/cashin_cubit.dart';
import '../cubit/cashin_state.dart';
import '../widgets/cashin_code_view.dart';
import '../widgets/cashin_confirm_view.dart';
import '../widgets/cashin_pick_view.dart';
import '../widgets/cashin_scan_view.dart';
import '../widgets/cashin_success_view.dart';

enum _CashinView { pick, scanning, coding }

class CashinScreen extends StatelessWidget {
  const CashinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CashinCubit>(
      create: (_) => getIt<CashinCubit>(),
      child: const _CashinOrchestrator(),
    );
  }
}

class _CashinOrchestrator extends StatefulWidget {
  const _CashinOrchestrator();

  @override
  State<_CashinOrchestrator> createState() => _CashinOrchestratorState();
}

class _CashinOrchestratorState extends State<_CashinOrchestrator> {
  _CashinView _view = _CashinView.pick;

  void _goScan() => setState(() => _view = _CashinView.scanning);
  void _goCode() => setState(() => _view = _CashinView.coding);

  void _reset() {
    setState(() => _view = _CashinView.pick);
    context.read<CashinCubit>().reset();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CashinCubit, CashinState>(
      listenWhen: (_, s) => s is CashinError,
      listener: (ctx, state) {
        if (state is CashinError) AppToast.show(ctx, state.message, isError: true);
      },
      child: BlocBuilder<CashinCubit, CashinState>(
        builder: (_, state) {
          if (state is CashinCompleted) {
            return CashinSuccessView(order: state.order);
          }

          if (state is CashinOrderFound || state is CashinCompleting) {
            final order = state is CashinOrderFound
                ? state.order
                : (state as CashinCompleting).order;
            return CashinConfirmView(
              order: order,
              isSubmitting: state is CashinCompleting,
              onCancel: _reset,
            );
          }

          return switch (_view) {
            _CashinView.pick => CashinPickView(onScan: _goScan, onCode: _goCode),
            _CashinView.scanning => CashinScanView(
                onBack: _reset,
                onSwitchToCode: _goCode,
              ),
            _CashinView.coding => CashinCodeView(
                onBack: _reset,
                onSwitchToScan: _goScan,
              ),
          };
        },
      ),
    );
  }
}
