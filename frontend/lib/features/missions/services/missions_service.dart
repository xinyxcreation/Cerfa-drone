import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/mission.dart';

class MissionsService {

  MissionsService._();

  static String _error(
    DioException error,
    String fallback,
  ) {

    final data =
        error.response?.data;

    if (data is Map) {

      final errorData =
          data['error'];

      if (errorData is Map &&
          errorData['message'] != null) {

        return errorData['message']
            .toString();
      }

      if (data['message'] != null) {

        return data['message']
            .toString();
      }
    }

    return fallback;
  }

  static Future<List<Mission>>
      getMissions() async {

    try {

      final response =
          await ApiClient.instance.get(
        '/auth/company/missions',
      );

      final data =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      final list =
          data['missions']
              as List<dynamic>? ??
          [];

      return list
          .whereType<Map>()
          .map(
            (item) =>
                Mission.fromJson(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
          )
          .toList();

    } on DioException catch (error) {

      throw Exception(
        _error(
          error,
          'Impossible de charger les missions.',
        ),
      );
    }
  }

  static Future<MissionReferenceData>
      getReferences() async {

    try {

      final response =
          await ApiClient.instance.get(
        '/auth/company/missions/references',
      );

      return MissionReferenceData.fromJson(
        Map<String, dynamic>.from(
          response.data as Map,
        ),
      );

    } on DioException catch (error) {

      throw Exception(
        _error(
          error,
          'Impossible de charger les données des missions.',
        ),
      );
    }
  }

  static Future<Mission>
      getMission(
    String missionId,
  ) async {

    try {

      final response =
          await ApiClient.instance.get(
        '/auth/company/missions/$missionId',
      );

      final data =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      return Mission.fromJson(
        Map<String, dynamic>.from(
          data['mission'] as Map,
        ),
      );

    } on DioException catch (error) {

      throw Exception(
        _error(
          error,
          'Impossible de charger la mission.',
        ),
      );
    }
  }

  static Future<Mission>
      createMission({
    required String clientId,
    required String pilotId,
    required String categoryId,
    String? statusId,
    required String title,
    String? description,
    DateTime? plannedAt,
    String? reference,
    String? notes,
    required String droneId,
    required String prefectureId,
    String? locationName,
    String? siteId,
    double? latitude,
    double? longitude,
    required String addressLine1,
    String? addressLine2,
    required String postalCode,
    required String city,
    String country = 'France',
  }) async {

    try {

      final response =
          await ApiClient.instance.post(
        '/auth/company/missions',
        data: {

          'client_id':
              clientId,

          'pilot_id':
              pilotId,

          'category_id':
              categoryId,

          'mission_status_id': statusId,

          'reference':
              reference,

          'title':
              title.trim(),

          'description':
              description,

          'planned_at':
              plannedAt?.toUtc().toIso8601String(),

          'notes':
              notes,

          'location': {

            'site_id':
                siteId,

            'drone_id':
                droneId,

            'prefecture_id':
                prefectureId,

            'name':
                locationName,

            'address_line_1':
                addressLine1.trim(),

            'address_line_2':
                addressLine2,

            'postal_code':
                postalCode.trim(),

            'city':
                city.trim(),

            'country':
                country,

            'latitude':
                latitude,

            'longitude':
                longitude,
          },
        },
      );

      final data =
          Map<String, dynamic>.from(
        response.data as Map,
      );

      return Mission.fromJson(
        Map<String, dynamic>.from(
          data['mission'] as Map,
        ),
      );

    } on DioException catch (error) {

      throw Exception(
        _error(
          error,
          'Impossible de créer la mission.',
        ),
      );
    }
  }

  static Future<void>
      setStatus(
    String missionId,
    String statusId,
  ) async {

    try {

      await ApiClient.instance.patch(
        '/auth/company/missions/$missionId/status',
        data: {
          'mission_status_id':
              statusId,
        },
      );

    } on DioException catch (error) {

      throw Exception(
        _error(
          error,
          'Impossible de modifier le statut.',
        ),
      );
    }
  }

  static Future<void>
      archive(
    String missionId,
  ) async {

    try {

      await ApiClient.instance.patch(
        '/auth/company/missions/$missionId/archive',
        data: {},
      );

    } on DioException catch (error) {

      throw Exception(
        _error(
          error,
          'Impossible d’archiver la mission.',
        ),
      );
    }
  }

  static Future<void>
      deleteMission(
    String missionId,
  ) async {

    try {

      await ApiClient.instance.delete(
        '/auth/company/missions/$missionId',
        data: {},
      );

    } on DioException catch (error) {

      throw Exception(
        _error(
          error,
          'Impossible de supprimer la mission.',
        ),
      );
    }
  }
}
