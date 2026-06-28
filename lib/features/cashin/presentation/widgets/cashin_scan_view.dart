import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/cashin_cubit.dart';
import '../cubit/cashin_state.dart';

class CashinScanView extends StatefulWidget {
  const CashinScanView({
    super.key,
    required this.onBack,
    required this.onSwitchToCode,
  });

  final VoidCallback onBack;
  final VoidCallback onSwitchToCode;

  @override
  State<CashinScanView> createState() => _CashinScanViewState();
}

class _CashinScanViewState extends State<CashinScanView> {
  late final MobileScannerController _controller;
  bool _hasScanned = false;
  bool _torchOn = false;

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
    context.read<CashinCubit>().lookupByCard(code);
  }

  void _toggleTorch() {
    _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CashinCubit, CashinState>(
      listener: (_, state) {
        if (state is CashinError || state is CashinInitial) {
          setState(() => _hasScanned = false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.ink,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: widget.onBack,
          ),
          title: Text(
            'Scanner la carte',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          actions: [
            GestureDetector(
              onTap: _toggleTorch,
              child: Container(
                margin: EdgeInsets.only(right: AppSpacing.md),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _torchOn ? Icons.flash_off_rounded : Icons.flash_on_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<CashinCubit, CashinState>(
          builder: (_, state) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: _ScanOverlay(onSwitchToCode: widget.onSwitchToCode),
                ),
                if (state is CashinLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x66000000),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay({required this.onSwitchToCode});
  final VoidCallback onSwitchToCode;

  static const _reticleW = 280.0;
  static const _reticleH = 176.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _DimPainter(_reticleW, _reticleH),
                ),
              ),
              SizedBox(
                width: _reticleW,
                height: _reticleH,
                child: CustomPaint(painter: _ReticlePainter()),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            children: [
              Text(
                'Présente la Carte GRAND-FRÈRE',
                style: AppTextStyles.h2.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Le QR code doit être bien centré dans le cadre.',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: onSwitchToCode,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: AppRadius.pill,
                    border: Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  child: Text(
                    'Saisir le code à la place',
                    style: AppTextStyles.buttonSmall.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DimPainter extends CustomPainter {
  const _DimPainter(this.w, this.h);
  final double w;
  final double h;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: w,
        height: h,
      ),
      AppRadius.md.topLeft,
    );
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(hole)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = const Color(0xAA000000));
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = 28.0;
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // top-left
    canvas.drawLine(Offset.zero, Offset(len, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, len), paint);
    // top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    // bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), paint);
    // bottom-right
    canvas.drawLine(
        Offset(size.width, size.height), Offset(size.width - len, size.height), paint);
    canvas.drawLine(
        Offset(size.width, size.height), Offset(size.width, size.height - len), paint);

    // scan line
    canvas.drawLine(
      Offset(len, size.height * 0.82),
      Offset(size.width - len, size.height * 0.82),
      Paint()
        ..color = AppColors.gold.withAlpha(220)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
