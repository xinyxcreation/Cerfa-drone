import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/company_site.dart';

class SitesService {
  SitesService._();

  static Future<List<CompanySite>> getSites() async {
    try {
      final response =
          await ApiClient.instance.get('/auth/company/sites');

      final data =
          Map<String, dynamic>.from(response.data as Map);


      final sites =
          data['sites'] as List<dynamic>? ?? [];

      return sites
          .map(
            (item) => CompanySite.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['message']?.toString() ??
            'Impossible de charger les sites.',
      );
    }
  }

  static Future<CompanySite> createSite({
    required String name,
    String? siteReference,
    String? description,
    String? clientId,
    String? categoryId,
    String? defaultDroneId,
    String? defaultPilotId,
    required String addressLine1,
    String? addressLine2,
    required String postalCode,
    required String city,
    String? country,
    double? latitude,
    double? longitude,
    String? prefectureId,
    bool isFavorite = false,
    String? notes,
  }) async {
    try {
      final response =
          await ApiClient.instance.post(
        '/auth/company/sites',
        data: {
          'site_reference': siteReference,
          'name': name.trim(),
          'description': description,
          'client_id': clientId,
          'category_id': categoryId,
          'default_drone_id': defaultDroneId,
          'default_pilot_id': defaultPilotId,
          'address_line_1': addressLine1.trim(),
          'address_line_2': addressLine2,
          'postal_code': postalCode.trim(),
          'city': city.trim(),
          'country': country ?? 'France',
          'latitude': latitude,
          'longitude': longitude,
          'prefecture_id': prefectureId,
          'is_favorite': isFavorite,
          'notes': notes,
        },
      );

      final data =
          Map<String, dynamic>.from(response.data as Map);

      return CompanySite.fromJson(
        Map<String, dynamic>.from(data['site'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['message']?.toString() ??
            'Impossible de créer le site.',
      );
    }
  }

  static Future<CompanySite> updateSite({
    required String siteId,
    required String name,
    String? siteReference,
    String? description,
    String? clientId,
    required String addressLine1,
    String? addressLine2,
    required String postalCode,
    required String city,
    String? country,
    double? latitude,
    double? longitude,
    String? prefectureId,
    bool isFavorite = false,
    String? notes,
  }) async {
    try {
      final response =
          await ApiClient.instance.put(
        '/auth/company/sites/$siteId',
        data: {
          'site_reference': siteReference,
          'name': name.trim(),
          'description': description,
          'client_id': clientId,
          'address_line_1': addressLine1.trim(),
          'address_line_2': addressLine2,
          'postal_code': postalCode.trim(),
          'city': city.trim(),
          'country': country ?? 'France',
          'latitude': latitude,
          'longitude': longitude,
          'prefecture_id': prefectureId,
          'is_favorite': isFavorite,
          'notes': notes,
        },
      );

      final data =
          Map<String, dynamic>.from(response.data as Map);

      return CompanySite.fromJson(
        Map<String, dynamic>.from(data['site'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['message']?.toString() ??
            'Impossible de modifier le site.',
      );
    }
  }

}
