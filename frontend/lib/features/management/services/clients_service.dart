import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/company_client.dart';

class ClientsService {
  ClientsService._();

  static Future<List<CompanyClient>> getClients() async {
    try {
      final response =
          await ApiClient.instance.get('/auth/company/clients');

      final data =
          Map<String, dynamic>.from(response.data as Map);

      final clients =
          data['clients'] as List<dynamic>? ?? [];

      return clients
          .map(
            (item) => CompanyClient.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['message']?.toString() ??
            'Impossible de charger les clients.',
      );
    }
  }

  static Future<CompanyClient> createClient({
    required String name,
    String? customerReference,
    String? contactName,
    String? email,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? postalCode,
    String? city,
    String? country,
    String? notes,
  }) async {
    try {
      final response =
          await ApiClient.instance.post(
        '/auth/company/clients',
        data: {
          'customer_reference': customerReference,
          'name': name.trim(),
          'contact_name': contactName,
          'email': email,
          'phone': phone,
          'address_line_1': addressLine1,
          'address_line_2': addressLine2,
          'postal_code': postalCode,
          'city': city,
          'country': country ?? 'France',
          'notes': notes,
        },
      );

      final data =
          Map<String, dynamic>.from(response.data as Map);

      return CompanyClient.fromJson(
        Map<String, dynamic>.from(data['client'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['message']?.toString() ??
            'Impossible de créer le client.',
      );
    }
  }
}
