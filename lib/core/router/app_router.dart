import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_bloc/auth_bloc.dart';
import '../auth/auth_bloc/auth_state.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/signup_vendor_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';
import '../../features/auth/presentation/pages/pending_approval_screen.dart';
import '../../features/shell/presentation/pages/app_shell.dart';
import 'go_router_refresh_stream.dart';
import 'routes.dart';

class AppRouter {
  AppRouter(this._authBloc) {
    router = GoRouter(
      initialLocation: Routes.splash,
      refreshListenable: GoRouterRefreshStream(_authBloc.stream),
      redirect: _guard,
      routes: [
        GoRoute(
          path: Routes.splash,
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.login,
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.signup,
          builder: (_, _) => const SignupVendorScreen(),
        ),
        GoRoute(
          path: Routes.forgot,
          builder: (_, _) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: Routes.resetPassword,
          builder: (_, state) {
            final extra = state.extra as ({String phone, String code});
            return ResetPasswordScreen(phone: extra.phone, code: extra.code);
          },
        ),
        GoRoute(
          path: Routes.pending,
          builder: (_, _) => const PendingApprovalScreen(),
        ),
        GoRoute(
          path: Routes.home,
          builder: (_, _) => const AppShell(),
        ),
      ],
    );
  }

  final AuthBloc _authBloc;
  late final GoRouter router;

  String? _guard(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final location = state.matchedLocation;

    if (location == Routes.splash) return null;

    if (authState is AuthInitial || authState is AuthLoading) {
      return Routes.splash;
    }

    if (authState is AuthUnauthenticated) {
      const authRoutes = {
        Routes.login,
        Routes.signup,
        Routes.forgot,
        Routes.resetPassword,
        Routes.pending,
      };
      return authRoutes.contains(location) ? null : Routes.login;
    }

    if (authState is AuthAuthenticated) {
      final isOnAuthScreen = location == Routes.login ||
          location == Routes.signup ||
          location == Routes.forgot ||
          location == Routes.resetPassword ||
          location == Routes.splash;
      return isOnAuthScreen ? Routes.home : null;
    }

    return null;
  }
}

