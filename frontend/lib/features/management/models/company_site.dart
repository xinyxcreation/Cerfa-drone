class CompanySite {
  const CompanySite({
    required this.id,
    required this.name,
    this.siteReference,
    this.description,
    this.clientId,
    this.clientName,
    this.categoryId,
    this.categoryLabel,
    this.defaultDroneId,
    this.defaultDroneName,
    this.defaultPilotId,
    this.defaultPilotEmail,
    required this.addressLine1,
    this.addressLine2,
    required this.postalCode,
    required this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.prefectureId,
    this.prefectureName,
    required this.isFavorite,
    required this.isActive,
    this.notes,
  });

  final String id;
  final String name;
  final String? siteReference;
  final String? description;
  final String? clientId;
  final String? clientName;
  final String? categoryId;
  final String? categoryLabel;
  final String? defaultDroneId;
  final String? defaultDroneName;
  final String? defaultPilotId;
  final String? defaultPilotEmail;
  final String addressLine1;
  final String? addressLine2;
  final String postalCode;
  final String city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? prefectureId;
  final String? prefectureName;
  final bool isFavorite;
  final bool isActive;
  final String? notes;

  factory CompanySite.fromJson(Map<String, dynamic> json) {
    bool boolValue(dynamic value) =>
        value == true ||
        value == 1 ||
        value?.toString() == '1' ||
        value?.toString().toLowerCase() == 'true';

    return CompanySite(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      siteReference: json['site_reference']?.toString(),
      description: json['description']?.toString(),
      clientId: json['client_id']?.toString(),
      clientName: json['client_name']?.toString(),
      categoryId: json['category_id']?.toString(),
      categoryLabel: json['category_label']?.toString(),
      defaultDroneId: json['default_drone_id']?.toString(),
      defaultDroneName: json['default_drone_name']?.toString(),
      defaultPilotId: json['default_pilot_id']?.toString(),
      defaultPilotEmail: json['default_pilot_email']?.toString(),
      addressLine1: json['address_line_1']?.toString() ?? '',
      addressLine2: json['address_line_2']?.toString(),
      postalCode: json['postal_code']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString(),
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      prefectureId: json['prefecture_id']?.toString(),
      prefectureName: json['prefecture_name']?.toString(),
      isFavorite: boolValue(json['is_favorite']),
      isActive: boolValue(json['is_active']),
      notes: json['notes']?.toString(),
    );
  }
}
