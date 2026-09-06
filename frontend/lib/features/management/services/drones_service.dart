import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/company_drone.dart';

class CreateDroneResult {
  const CreateDroneResult({
    required this.drone,
    this.warning,
  });

  final CompanyDrone drone;
  final String? warning;

  bool get hasWarning =>
      warning != null && warning!.isNotEmpty;
}

class DronesService {
  DronesService._();

  static Future<List<CompanyDrone>> getDrones() async {
    try {
      final response =
          await ApiClient.instance.get(
        '/auth/company/drones',
      );

      final data =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      final drones =
          data['drones'] as List<dynamic>? ?? [];

      return drones
          .map(
            (item) => CompanyDrone.fromJson(
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
          'Impossible de charger les drones.',
        ),
      );
    }
  }

  static Future<CreateDroneResult> createDrone({
    String? nickname,
    required String manufacturer,
    required String model,
    required String serialNumber,
    required String alphatangoAircraftNumber,
    String? droneClass,
    int? weightG,
    String? notes,
  }) async {
    try {
      final response =
          await ApiClient.instance.post(
        '/auth/company/drones',
        data: {
          'nickname':
              nickname == null ||
                      nickname.trim().isEmpty
                  ? null
                  : nickname.trim(),
          'manufacturer':
              manufacturer.trim(),
          'model':
              model.trim(),
          'serial_number':
              serialNumber.trim(),
          'alphatango_aircraft_number':
              alphatangoAircraftNumber.trim(),
          'drone_class':
              droneClass == null ||
                      droneClass.trim().isEmpty
                  ? null
                  : droneClass.trim(),
          'weight_g': weightG,
          'notes':
              notes == null ||
                      notes.trim().isEmpty
                  ? null
                  : notes.trim(),
        },
      );

      final data =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      final droneData =
          data['drone'];

      if (droneData is! Map) {
        throw Exception(
          'Réponse invalide lors de la création du drone.',
        );
      }

      String? warning;

      final warningData =
          data['warning'];

      if (warningData is Map) {
        warning =
            warningData['message']?.toString();
      }

      return CreateDroneResult(
        drone: CompanyDrone.fromJson(
          Map<String, dynamic>.from(
            droneData,
          ),
        ),
        warning: warning,
      );
    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible d’ajouter le drone.',
        ),
      );
    }
  }

static Future<CompanyDrone> updateDrone({
    required String droneId,
    String? nickname,
    required String manufacturer,
    required String model,
    required String serialNumber,
    required String alphatangoAircraftNumber,
    String? droneClass,
    int? weightG,
    String? notes,
  }) async {
    try {
      final response =
          await ApiClient.instance.put(
        '/auth/company/drones/$droneId',
        data: {
          'nickname':
              nickname == null ||
                      nickname.trim().isEmpty
                  ? null
                  : nickname.trim(),
          'manufacturer':
              manufacturer.trim(),
          'model':
              model.trim(),
          'serial_number':
              serialNumber.trim(),
          'alphatango_aircraft_number':
              alphatangoAircraftNumber.trim(),
          'drone_class':
              droneClass == null ||
                      droneClass.trim().isEmpty
                  ? null
                  : droneClass.trim(),
          'weight_g': weightG,
          'notes':
              notes == null ||
                      notes.trim().isEmpty
                  ? null
                  : notes.trim(),
        },
      );

      final data =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      return CompanyDrone.fromJson(
        Map<String, dynamic>.from(
          data['drone'] as Map,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de modifier le drone.',
        ),
      );
    }
  }

  static Future<void> activateDrone(
    String droneId,
  ) async {
    try {
      await ApiClient.instance.patch(
        '/auth/company/drones/$droneId/activate',
        data: {},
      );
    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de réactiver le drone.',
        ),
      );
    }
  }

  static Future<void> deleteDrone(
    String droneId,
  ) async {
    try {
      await ApiClient.instance.delete(
        '/auth/company/drones/$droneId/delete',
        data: {},
      );
    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de supprimer le drone.',
        ),
      );
    }
  }

  static Future<void> deactivateDrone(
    String droneId,
  ) async {
    try {
      await ApiClient.instance.delete(
        '/auth/company/drones/$droneId',
        data: {},
      );
    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de désactiver le drone.',
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
      final errorData = data['error'];

      if (errorData is Map &&
          errorData['message'] != null) {
        return errorData['message'].toString();
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    return fallback;
  }
}
