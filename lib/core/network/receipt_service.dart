import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:museum_kiosk/core/network/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'receipt_service.g.dart';

final _log = Logger('kiosk.receipt');

@Riverpod(keepAlive: true)
ReceiptService receiptService(ReceiptServiceRef ref) {
  return ReceiptService(ref.watch(apiClientProvider));
}

class ReceiptService {
  const ReceiptService(this._dio);

  final Dio _dio;

  /// Best-effort receipt webhook.  Never throws — failure must not block
  /// the confirmation screen (integration-standards.mdc).
  Future<void> sendReceipt({required String orderId}) async {
    try {
      _log.info('receipt_sending orderId=$orderId');
      await _dio.post<void>(
        '/v1/orders/$orderId/receipt',
        data: <String, String>{'orderId': orderId},
      );
      _log.info('receipt_sent orderId=$orderId');
    } on DioException catch (e) {
      _log.warning('receipt_send_failed orderId=$orderId: ${e.message}');
    } catch (e, st) {
      _log.severe('receipt_send_error orderId=$orderId', e, st);
    }
  }
}
