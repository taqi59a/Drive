import 'package:dio/dio.dart';
import '../config/app_config.dart';

class DioClient {
  DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.proxyBaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.appToken}',
        },
      ),
    );

    dio.interceptors.addAll([
      _LoggingInterceptor(),
      _RetryInterceptor(dio),
    ]);

    return dio;
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConfig.isDebug) {
      // ignore: avoid_print
      print('[DIO] ${options.method} ${options.path}');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConfig.isDebug) {
      // ignore: avoid_print
      print('[DIO] Error: ${err.message}');
    }
    handler.next(err);
  }
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this.dio);
  final Dio dio;
  static const int _maxRetries = 2;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final retryCount = (options.extra['retryCount'] as int?) ?? 0;

    final shouldRetry = retryCount < _maxRetries &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            (err.response?.statusCode != null && err.response!.statusCode! >= 500));

    if (shouldRetry) {
      options.extra['retryCount'] = retryCount + 1;
      await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
      try {
        handler.resolve(await dio.fetch(options));
        return;
      } catch (_) {}
    }
    handler.next(err);
  }
}
