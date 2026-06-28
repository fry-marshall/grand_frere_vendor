import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_bloc/auth_bloc.dart';
import '../../../../core/auth/auth_bloc/auth_state.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;
  late final Animation<double> _offset;
  bool _timerDone = false;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _offset = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _float, curve: Curves.easeInOut),
    );

    context.read<AuthBloc>().stream.listen((_) {
      if (mounted && _timerDone) _tryAdvance();
    }); // ignore: discarded_futures

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      _timerDone = true;
      _tryAdvance();
    });
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  void _tryAdvance() {
    if (!mounted || !_timerDone) return;
    switch (context.read<AuthBloc>().state) {
      case AuthUnauthenticated():
        context.go(Routes.login);
      case AuthAuthenticated():
        context.go(Routes.home);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (_, _) => _tryAdvance(),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: Center(
          child: AnimatedBuilder(
            animation: _offset,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, _offset.value),
              child: child,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  'Vendeur',
                  style: AppTextStyles.h3.copyWith(color: AppColors.gold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
