class CompanyDrone {
  const CompanyDrone({
    required this.id,
    required this.companyId,
    required this.nickname,
    required this.manufacturer,
    required this.model,
    required this.serialNumber,
    required this.alphatangoAircraftNumber,
    required this.droneClass,
    required this.weightG,
    required this.notes,
    required this.isActive,
  });

  final String id;
  final String companyId;
  final String? nickname;
  final String manufacturer;
  final String model;
  final String serialNumber;
  final String alphatangoAircraftNumber;
  final String? droneClass;
  final int? weightG;
  final String? notes;
  final bool isActive;

  factory CompanyDrone.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawActive = json['is_active'];

    return CompanyDrone(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      nickname: json['nickname']?.toString(),
      manufacturer:
          json['manufacturer']?.toString() ?? '',
      model:
          json['model']?.toString() ?? '',
      serialNumber:
          json['serial_number']?.toString() ?? '',
      alphatangoAircraftNumber:
          json['alphatango_aircraft_number']?.toString() ?? '',
      droneClass:
          json['drone_class']?.toString(),
      weightG: json['weight_g'] is num
          ? (json['weight_g'] as num).toInt()
          : null,
      notes:
          json['notes']?.toString(),
      isActive:
          rawActive == true ||
          rawActive == 1 ||
          rawActive?.toString().toLowerCase() == 'true' ||
          rawActive?.toString() == '1',
    );
  }

  String get displayName {
    if (nickname != null &&
        nickname!.trim().isNotEmpty) {
      return nickname!.trim();
    }

    return '$manufacturer $model'.trim();
  }

  String get subtitle {
    final value =
        '$manufacturer $model'.trim();

    if (value.isEmpty) {
      return 'Drone';
    }

    return value;
  }

  String get weightLabel {
    if (weightG == null) {
      return 'Poids non renseigné';
    }

    return '${weightG!} g';
  }
}
