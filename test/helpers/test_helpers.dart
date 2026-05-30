import 'package:mocktail/mocktail.dart';
import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:museum_kiosk/core/database/database.dart';
import 'package:museum_kiosk/core/payment/payment_service.dart';

// Shared test config — overrides appConfigProvider in ProviderContainer.
const testConfig = AppConfig(
  environment: 'development',
  museumName: 'Test Museum',
  sumupAffiliateKey: '',
  adminPin: '1234',
  idleTimeoutSeconds: 60,
  ticketPriceCents: 400,
  kioskId: 'test-kiosk',
  logLevel: 'WARNING',
  backendUrl: 'http://localhost:8000',
);

class MockPaymentService extends Mock implements PaymentService {}

// Returns a fresh in-memory database. Caller must close it in tearDown.
KioskDatabase makeTestDb() => KioskDatabase.forTesting();
