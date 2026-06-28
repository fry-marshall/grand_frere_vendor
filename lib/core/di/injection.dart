import 'package:get_it/get_it.dart';

import '../auth/auth_bloc/auth_bloc.dart';
import '../auth/auth_status.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../router/app_router.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/school_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/school_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/school_repository.dart';
import '../../features/auth/presentation/bloc/forgot_password_bloc/forgot_password_bloc.dart';
import '../../features/auth/presentation/bloc/login_bloc/login_bloc.dart';
import '../../features/auth/presentation/bloc/reset_password_bloc/reset_password_bloc.dart';
import '../../features/auth/presentation/bloc/signup_vendor_bloc/signup_vendor_bloc.dart';
import '../../features/vendor/data/datasources/vendor_remote_datasource.dart';
import '../../features/vendor/data/repositories/vendor_repository_impl.dart';
import '../../features/vendor/domain/repositories/vendor_repository.dart';
import '../../features/vendor/presentation/cubit/dashboard_cubit.dart';
import '../../features/vendor/presentation/cubit/vendor_cubit.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // ── Core ────────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton(() => TokenStorage());
  getIt.registerLazySingleton(() => AuthStatus());
  getIt.registerLazySingleton(
    () => AuthInterceptor(getIt<TokenStorage>(), getIt<AuthStatus>()),
  );
  getIt.registerLazySingleton(
    () => ApiClient(getIt<AuthInterceptor>()),
  );

  // ── Auth ─────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // ── Schools ───────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<SchoolRemoteDataSource>(
    () => SchoolRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SchoolRepository>(
    () => SchoolRepositoryImpl(getIt<SchoolRemoteDataSource>()),
  );

  // ── Vendor ────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<VendorRemoteDataSource>(
    () => VendorRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<VendorRepository>(
    () => VendorRepositoryImpl(getIt<VendorRemoteDataSource>()),
  );

  // ── Global BLoCs (singletons) ─────────────────────────────────────────────
  getIt.registerSingleton(
    AuthBloc(getIt<TokenStorage>(), getIt<AuthStatus>()),
  );
  getIt.registerSingleton(VendorCubit(getIt<VendorRepository>()));

  // ── Router ────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton(() => AppRouter(getIt<AuthBloc>()));

  // ── Feature BLoCs (factory — new instance per screen) ─────────────────────
  getIt.registerFactory(() => LoginBloc(getIt<AuthRepository>()));
  getIt.registerFactory(
    () => SignupVendorBloc(getIt<AuthRepository>(), getIt<SchoolRepository>()),
  );
  getIt.registerFactory(() => ForgotPasswordBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => ResetPasswordBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => DashboardCubit(getIt<VendorRepository>()));
}
