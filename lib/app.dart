import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:grand_frere_vendor/core/storage/token_storage.dart';

import 'core/auth/auth_bloc/auth_bloc.dart';
import 'core/auth/auth_bloc/auth_event.dart';
import 'core/auth/auth_bloc/auth_state.dart';
import 'core/di/injection.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/vendor/presentation/cubit/vendor_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppRouter _appRouter;
  bool _pushInitialized = false;

  @override
  void initState() {
    super.initState();
    _appRouter = getIt<AppRouter>();
    getIt<AuthBloc>().add(const AuthCheckRequested());
    TokenStorage tokenStorage = getIt<TokenStorage>();
    tokenStorage.clearTokens();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<VendorCubit>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<VendorCubit>().load();
            if (!_pushInitialized) {
              _pushInitialized = true;
              getIt<FirebaseNotificationService>().init();
            }
          } else if (state is AuthUnauthenticated) {
            context.read<VendorCubit>().reset();
          }
        },
        child: MaterialApp.router(
          title: 'Grand Frère — Vendeur',
          theme: AppTheme.main,
          routerConfig: _appRouter.router,
          debugShowCheckedModeBanner: false,
          locale: const Locale('fr'),
          supportedLocales: const [Locale('fr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}

