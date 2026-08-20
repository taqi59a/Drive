class AppConfig {
  AppConfig._();

  static const String proxyBaseUrl = String.fromEnvironment(
    'PROXY_BASE_URL',
    defaultValue: 'http://localhost:8787',
  );

  static const String appToken = String.fromEnvironment(
    'APP_TOKEN',
    defaultValue: 'dev-token',
  );

  static const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
}
