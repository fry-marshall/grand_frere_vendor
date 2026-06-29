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
import '../../features/cashin/data/datasources/cashin_remote_datasource.dart';
import '../../features/cashin/data/repositories/cashin_repository_impl.dart';
import '../../features/cashin/domain/repositories/cashin_repository.dart';
import '../../features/cashin/presentation/cubit/cashin_cubit.dart';
import '../../features/vendor/data/datasources/vendor_remote_datasource.dart';
import '../../features/vendor/data/repositories/vendor_repository_impl.dart';
import '../../features/vendor/domain/repositories/vendor_repository.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/menu/data/datasources/items_remote_datasource.dart';
import '../../features/menu/data/repositories/items_repository_impl.dart';
import '../../features/menu/domain/repositories/items_repository.dart';
import '../../features/menu/presentation/cubit/items_cubit.dart';
import '../../features/balance/data/datasources/balance_remote_datasource.dart';
import '../../features/balance/data/repositories/balance_repository_impl.dart';
import '../../features/balance/domain/repositories/balance_repository.dart';
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
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

  // ── Cashin ────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<CashinRemoteDataSource>(
    () => CashinRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CashinRepository>(
    () => CashinRepositoryImpl(getIt<CashinRemoteDataSource>()),
  );

  // ── Vendor ────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<VendorRemoteDataSource>(
    () => VendorRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<VendorRepository>(
    () => VendorRepositoryImpl(getIt<VendorRemoteDataSource>()),
  );

  // ── Orders ────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(getIt<OrdersRemoteDataSource>()),
  );

  // ── Notifications ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(getIt<NotificationsRemoteDataSource>()),
  );

  // ── Balance & Withdrawals ─────────────────────────────────────────────────
  getIt.registerLazySingleton<BalanceRemoteDataSource>(
    () => BalanceRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<BalanceRepository>(
    () => BalanceRepositoryImpl(getIt<BalanceRemoteDataSource>()),
  );

  // ── Menu (Items) ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<ItemsRemoteDataSource>(
    () => ItemsRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ItemsRepository>(
    () => ItemsRepositoryImpl(getIt<ItemsRemoteDataSource>()),
  );

  // ── Global BLoCs (singletons) ─────────────────────────────────────────────
  getIt.registerSingleton(
    AuthBloc(getIt<TokenStorage>(), getIt<AuthStatus>()),
  );
  getIt.registerSingleton(VendorCubit(getIt<VendorRepository>()));
  getIt.registerSingleton(OrdersCubit(getIt<OrdersRepository>()));
  getIt.registerSingleton(ItemsCubit(getIt<ItemsRepository>()));
  getIt.registerSingleton(NotificationsCubit(getIt<NotificationsRepository>()));

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
  getIt.registerFactory(() => CashinCubit(getIt<CashinRepository>()));
}
