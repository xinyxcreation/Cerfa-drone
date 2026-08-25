import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class ProfileService {
  ProfileService._();

  static Future<ProfileData> getProfile() async {
    try {
      final response = await ApiClient.instance.get(
        '/auth/me',
      );

      final data = Map<String, dynamic>.from(
        response.data as Map,
      );

      if (data['success'] != true) {
        throw Exception(
          data['message'] ??
          'Impossible de récupérer le profil.',
        );
      }

      return ProfileData.fromJson(
        Map<String, dynamic>.from(
          data['user'] as Map,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de récupérer le profil.',
        ),
      );
    }
  }

  static Future<ProfileData> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
  }) async {
    try {
      final response = await ApiClient.instance.put(
        '/auth/me',
        data: {
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'email': email.trim().toLowerCase(),
          'phone': phone == null || phone.trim().isEmpty
          ? null
          : phone.trim(),
        },
      );

      final data = Map<String, dynamic>.from(
        response.data as Map,
      );

      if (data['success'] != true) {
        throw Exception(
          data['message'] ??
          'Impossible de modifier le profil.',
        );
      }

      return ProfileData.fromJson(
        Map<String, dynamic>.from(
          data['user'] as Map,
        ),
      );
    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de modifier le profil.',
        ),
      );
    }
  }

  static Future<bool> setPilot(bool enabled) async {
    try {
      final response = enabled
          ? await ApiClient.instance.put(
              '/auth/me/pilot',
            )
          : await ApiClient.instance.delete(
              '/auth/me/pilot',
            );

      final data = Map<String, dynamic>.from(
        response.data as Map,
      );

      if (data['success'] != true) {
        throw Exception(
          data['message'] ??
              'Impossible de modifier le statut pilote.',
        );
      }

      return data['is_pilot'] == true;
    } on DioException catch (error) {
      throw Exception(
        _messageFromError(
          error,
          'Impossible de modifier le statut pilote.',
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

class ProfileData {
  const ProfileData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.isActive,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final bool isActive;

  factory ProfileData.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfileData(
      id: json['id'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      isActive: json['is_active'] == true ||
      json['is_active'] == 1,
    );
  }
}
