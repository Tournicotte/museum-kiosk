import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:museum_kiosk/core/config/app_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

final _log = Logger('kiosk.api');

@Riverpod(keepAlive: true)
Dio apiClient(ApiClientRef ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.backendUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: <String, String>{
        'X-Kiosk-Id': config.kioskId,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  dio.interceptors.add(_LoggingInterceptor());
  ref.onDispose(() => dio.close());
  return dio;
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.fine('api_request ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log.fine(
      'api_response ${response.statusCode} ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.warning(
      'api_error ${err.requestOptions.path}: ${err.message}',
    );
    handler.next(err);
  }
}
