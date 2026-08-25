import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/company_pilot.dart';

class PilotsService {
  PilotsService._();

  static Future<List<CompanyPilot>> getPilots() async {
    try {
      final response = await ApiClient.instance.get(
        '/auth/company/pilots',
      );

      final data =
      Map<String, dynamic>.from(
        response.data as Map,
      );

      final pilots =
      data['pilots'] as List<dynamic>? ?? [];

      return pilots
      .map(
        (item) => CompanyPilot.fromJson(
          Map<String, dynamic>.from(
            item as Map,
          ),
        ),
      )
      .toList();

    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de charger les pilotes.',
        ),
      );
    }
  }

  static Future<CompanyPilot> createPilot({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response =
      await ApiClient.instance.post(
        '/auth/company/pilots',
        data: {
          'firstname': firstname.trim(),
          'lastname': lastname.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'phone': phone == null ||
          phone.trim().isEmpty
          ? null
          : phone.trim(),
        },
      );

      final data =
      Map<String, dynamic>.from(
        response.data as Map,
      );

      return CompanyPilot.fromJson(
        Map<String, dynamic>.from(
          data['pilot'] as Map,
        ),
      );

    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de créer le pilote.',
        ),
      );
    }
  }

  static Future<void> setCurrentUserPilot(
    bool isPilot,
  ) async {
    try {
      final method = isPilot ? 'put' : 'delete';

      if (method == 'put') {
        await ApiClient.instance.put(
          '/auth/me/pilot',
          data: {},
        );
      } else {
        await ApiClient.instance.delete(
          '/auth/me/pilot',
        );
      }

    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          isPilot
              ? 'Impossible de devenir pilote.'
              : 'Impossible de retirer le statut pilote.',
        ),
      );
    }
  }

  static Future<void> deactivatePilot(
    String pilotId,
  ) async {
    try {
      await ApiClient.instance.delete(
        '/auth/company/pilots/$pilotId',
      );

    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de désactiver le pilote.',
        ),
      );
    }
  }

  static String _messageFromError(
    DioException error,
    String fallback,
  ) {
    final data = error.response?.data;

    if (data is Map) {
      final message = data['message'];

      if (message is String &&
        message.trim().isNotEmpty) {
        return message;
        }
    }

    return fallback;
  }
}
