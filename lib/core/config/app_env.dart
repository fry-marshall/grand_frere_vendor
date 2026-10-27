enum AppEnv {
  staging,
  production;

  static final current = AppEnv.values.byName(
    const String.fromEnvironment('APP_ENV', defaultValue: 'staging'),
  );

  String get envFile => '.env.$name';
  bool get isProduction => this == AppEnv.production;
}
