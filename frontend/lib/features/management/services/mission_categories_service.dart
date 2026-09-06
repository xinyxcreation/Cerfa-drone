import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/mission_category.dart';

class MissionCategoriesService {
  MissionCategoriesService._();

  static Future<List<MissionCategory>> getCategories() async {
    try {
      final response =
          await ApiClient.instance.get('/auth/company/categories');

      final data =
          Map<String, dynamic>.from(response.data as Map);

      final categories =
          data['categories'] as List<dynamic>? ?? [];

      return categories
          .map(
            (item) => MissionCategory.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['message']?.toString() ??
            'Impossible de charger les catégories.',
      );
    }
  }

  static Future<MissionCategory> createCategory({
    required String code,
    required String label,
    String? description,
    int sortOrder = 0,
    String? defaultDroneId,
  }) async {
    try {
      final response =
          await ApiClient.instance.post(
        '/auth/company/categories',
        data: {
          'code': code.trim(),
          'label': label.trim(),
          'description': description,
          'sort_order': sortOrder,
          'default_drone_id': defaultDroneId,
        },
      );

      final data =
          Map<String, dynamic>.from(response.data as Map);

      return MissionCategory.fromJson(
        Map<String, dynamic>.from(data['category'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['message']?.toString() ??
            'Impossible de créer la catégorie.',
      );
    }
  }

  static Future<MissionCategory> updateCategory({
    required String categoryId,
    required String code,
    required String label,
    String? description,
    int sortOrder = 0,
    String? defaultDroneId,
  }) async {
    try {
      final response =
          await ApiClient.instance.put(
        '/auth/company/categories/$categoryId',
        data: {
          'code': code.trim(),
          'label': label.trim(),
          'description': description,
          'sort_order': sortOrder,
          'default_drone_id': defaultDroneId,
        },
      );

      final data =
          Map<String, dynamic>.from(response.data as Map);

      return MissionCategory.fromJson(
        Map<String, dynamic>.from(data['category'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['message']?.toString() ??
            'Impossible de modifier la catégorie.',
      );
    }
  }
}
