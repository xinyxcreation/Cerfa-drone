class MissionCategory {
  const MissionCategory({
    required this.id,
    required this.code,
    required this.label,
    this.description,
    required this.sortOrder,
    required this.isActive,
    this.defaultDroneId,
    this.defaultDroneName,
  });

  final String id;
  final String code;
  final String label;
  final String? description;
  final int sortOrder;
  final bool isActive;

  final String? defaultDroneId;
  final String? defaultDroneName;

  factory MissionCategory.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawActive = json['is_active'];

    return MissionCategory(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString(),
      sortOrder:
          int.tryParse(
                json['sort_order']?.toString() ?? '',
              ) ??
              0,
      isActive:
          rawActive == true ||
          rawActive == 1 ||
          rawActive?.toString() == '1' ||
          rawActive?.toString().toLowerCase() == 'true',
      defaultDroneId:
          json['default_drone_id']?.toString(),
      defaultDroneName:
          json['default_drone_name']?.toString(),
    );
  }
}
