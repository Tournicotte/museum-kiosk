import 'package:flutter_riverpod/flutter_riverpod.dart';

// All config from --dart-define at build time. No module-level singletons.
// Override appConfigProvider in main() ProviderScope.
final class AppConfig {
  const AppConfig({
    required this.environment,
    required this.museumName,
    required this.sumupAffiliateKey,
    required this.adminPin,
    required this.idleTimeoutSeconds,
    required this.logLevel,
    required this.backendUrl,
  });

  final String environment;
  final String museumName;
  final String sumupAffiliateKey;
  final String adminPin;
  final int idleTimeoutSeconds;
  final String logLevel;
  final String backendUrl;

  factory AppConfig.fromEnvironment() => const AppConfig(
        environment: String.fromEnvironment('ENV', defaultValue: 'development'),
        museumName: String.fromEnvironment('MUSEUM_NAME', defaultValue: 'Museum'),
        sumupAffiliateKey: String.fromEnvironment('SUMUP_AFFILIATE_KEY'),
        adminPin: String.fromEnvironment('ADMIN_PIN', defaultValue: '0000'),
        idleTimeoutSeconds: int.fromEnvironment('IDLE_TIMEOUT_SECONDS', defaultValue: 60),
        logLevel: String.fromEnvironment('LOG_LEVEL', defaultValue: 'INFO'),
        backendUrl: String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8000'),
      );

  bool get isProduction => environment == 'production';
  bool get isDevelopment => environment == 'development';
}

// Overridden in main() — throws if accessed without override.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider must be overridden in ProviderScope'),
);
