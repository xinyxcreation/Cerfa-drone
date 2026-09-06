class Mission {

  const Mission({
    required this.id,
    required this.companyId,
    required this.clientId,
    required this.clientName,
    required this.pilotId,
    required this.pilotFirstName,
    required this.pilotLastName,
    required this.pilotEmail,
    required this.categoryId,
    required this.categoryCode,
    required this.categoryLabel,
    required this.statusId,
    required this.statusCode,
    required this.statusLabel,
    required this.reference,
    required this.title,
    required this.description,
    required this.plannedAt,
    required this.startedAt,
    required this.completedAt,
    required this.isArchived,
    required this.notes,
  });

  final String id;
  final String companyId;

  final String clientId;
  final String clientName;

  final String pilotId;
  final String pilotFirstName;
  final String pilotLastName;
  final String pilotEmail;

  final String categoryId;
  final String categoryCode;
  final String categoryLabel;

  final String statusId;
  final String statusCode;
  final String statusLabel;

  final String? reference;
  final String title;
  final String? description;

  final DateTime? plannedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  final bool isArchived;
  final String? notes;

  factory Mission.fromJson(
    Map<String, dynamic> json,
  ) {

    bool boolValue(dynamic value) =>
        value == true ||
        value == 1 ||
        value?.toString().toLowerCase() == 'true' ||
        value?.toString() == '1';

    DateTime? dateValue(dynamic value) =>
        value == null
            ? null
            : DateTime.tryParse(
                value.toString(),
              );

    return Mission(
      id: json['id']?.toString() ?? '',
      companyId:
          json['company_id']?.toString() ?? '',

      clientId:
          json['client_id']?.toString() ?? '',
      clientName:
          json['client_name']?.toString() ?? '',

      pilotId:
          json['pilot_id']?.toString() ?? '',
      pilotFirstName:
          json['pilot_firstname']?.toString() ?? '',
      pilotLastName:
          json['pilot_lastname']?.toString() ?? '',
      pilotEmail:
          json['pilot_email']?.toString() ?? '',

      categoryId:
          json['category_id']?.toString() ?? '',
      categoryCode:
          json['category_code']?.toString() ?? '',
      categoryLabel:
          json['category_label']?.toString() ?? '',

      statusId:
          json['mission_status_id']?.toString() ?? '',
      statusCode:
          json['status_code']?.toString() ?? '',
      statusLabel:
          json['status_label']?.toString() ?? '',

      reference:
          json['reference']?.toString(),

      title:
          json['title']?.toString() ?? '',

      description:
          json['description']?.toString(),

      plannedAt:
          dateValue(json['planned_at']),

      startedAt:
          dateValue(json['started_at']),

      completedAt:
          dateValue(json['completed_at']),

      isArchived:
          boolValue(json['is_archived']),

      notes:
          json['notes']?.toString(),
    );
  }

  String get pilotName {

    final name =
        '$pilotFirstName $pilotLastName'
        .trim();

    return name.isEmpty
        ? pilotEmail
        : name;
  }
}

class MissionReferenceData {

  const MissionReferenceData({
    required this.clients,
    required this.pilots,
    required this.drones,
    required this.categories,
    required this.statuses,
    required this.prefectures,
  });

  final List<Map<String, dynamic>> clients;
  final List<Map<String, dynamic>> pilots;
  final List<Map<String, dynamic>> drones;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> statuses;
  final List<Map<String, dynamic>> prefectures;

  factory MissionReferenceData.fromJson(
    Map<String, dynamic> json,
  ) {

    List<Map<String, dynamic>> list(
      dynamic value,
    ) {

      if (value is! List) {
        return [];
      }

      return value
          .whereType<Map>()
          .map(
            (item) =>
                Map<String, dynamic>.from(
                  item,
                ),
          )
          .toList();
    }

    return MissionReferenceData(
      clients: list(json['clients']),
      pilots: list(json['pilots']),
      drones: list(json['drones']),
      categories: list(json['categories']),
      statuses: list(json['statuses']),
      prefectures: list(json['prefectures']),
    );
  }
}
