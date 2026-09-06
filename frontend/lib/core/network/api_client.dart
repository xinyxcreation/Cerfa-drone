import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/session_storage.dart';

class ApiClient {
  ApiClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (
        options,
        handler,
      ) async {
        final token =
        await SessionStorage.getAccessToken();

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] =
          'Bearer $token';
        }

        // Les DELETE sans body ne doivent pas annoncer
        // application/json, sinon Fastify attend un body JSON.
        if (options.method.toUpperCase() == 'DELETE' &&
            options.data == null) {
          options.headers.remove('Content-Type');
          options.contentType = null;
        }

        debugPrint(
          'API ${options.method} ${options.uri} '
          'contentType=${options.contentType} '
          'data=${options.data}',
        );

        handler.next(options);
      },

      onError: (
        error,
        handler,
      ) async {
        if (error.response?.statusCode == 401) {
          await SessionStorage.clear();
        }

        handler.next(error);
      },
    ),
  );
}
