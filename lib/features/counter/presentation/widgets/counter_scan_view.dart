import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/counter_cubit.dart';
import '../cubit/counter_state.dart';

class CounterScanView extends StatefulWidget {
  const CounterScanView({
    super.key,
    required this.onDetected,
    required this.onBack,
  });

  final ValueChanged<String> onDetected;
  final VoidCallback onBack;

  @override
  State<CounterScanView> createState() => _CounterScanViewState();
}

class _CounterScanViewState extends State<CounterScanView> {
  late final MobileScannerController _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;
    setState(() => _hasScanned = true);
    // Stop decoding while the lookup runs, or the card still in frame keeps
    // re-firing the same lookup.
    _controller.stop();
    widget.onDetected(code);
  }

  /// Leave time to move the card away before decoding again.
  void _resumeScanningAfterDelay() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _controller.start();
      setState(() => _hasScanned = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CounterCubit, CounterState>(
      listenWhen: (_, s) => s is CounterScanError,
      listener: (_, _) => _resumeScanningAfterDelay(),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        appBar: AppBar(
          backgroundColor: AppColors.ink,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.white,
              size: 28,
            ),
            onPressed: widget.onBack,
          ),
          title: Text(
            'Vente au comptoir',
            style: AppTextStyles.h3.copyWith(color: AppColors.white),
          ),
        ),
        body: Stack(
          children: [
            MobileScanner(controller: _controller, onDetect: _onDetect),
            Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.lg,
                  border: Border.all(color: AppColors.gold, width: 3),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.xxl,
              child: BlocBuilder<CounterCubit, CounterState>(
                builder: (_, state) => state is CounterLoadingPreview
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      )
                    : Text(
                        "Scanne la Carte GRAND-FRÈRE de l'élève",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
