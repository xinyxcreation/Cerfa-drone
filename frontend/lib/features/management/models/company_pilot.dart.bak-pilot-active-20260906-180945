class PilotCertification {
  const PilotCertification({
    required this.id,
    required this.code,
    required this.label,
    required this.description,
    required this.reference,
    required this.obtainedAt,
    required this.expiresAt,
    required this.reminderDays,
    required this.isValid,
    required this.notes,
  });

  final String id;
  final String code;
  final String label;
  final String? description;
  final String? reference;
  final DateTime? obtainedAt;
  final DateTime? expiresAt;
  final int? reminderDays;
  final bool isValid;
  final String? notes;

  factory PilotCertification.fromJson(
    Map<String, dynamic> json,
  ) {
    return PilotCertification(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString(),
      reference: json['reference']?.toString(),
      obtainedAt: json['obtained_at'] != null
          ? DateTime.tryParse(
              json['obtained_at'].toString(),
            )
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(
              json['expires_at'].toString(),
            )
          : null,
      reminderDays: json['reminder_days'] is num
          ? (json['reminder_days'] as num).toInt()
          : null,
      notes: json['notes']?.toString(),
    isValid:
        json['is_valid'] == true ||
        json['is_valid'] == 1 ||
        json['is_valid']?.toString().toLowerCase() == 'true' ||
        json['is_valid']?.toString() == '1',

    );
  }

  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }

    final today = DateTime.now();

    return expiresAt!.isBefore(
      DateTime(
        today.year,
        today.month,
        today.day,
      ),
    );
  }

  bool get isExpiringSoon {
    if (expiresAt == null || isExpired) {
      return false;
    }

    final today = DateTime.now();
    final reminder = reminderDays ?? 30;

    final limit = today.add(
      Duration(days: reminder),
    );

    return !expiresAt!.isAfter(limit);
  }
}

class CompanyPilot {
  const CompanyPilot({
    required this.id,
    this.companyId,
    this.companyName,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.joinedAt,
    required this.role,
    required this.certifications,
  });

  final String id;

  final String? companyId;
  final String? companyName;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final DateTime? joinedAt;
  final String role;
  final List<PilotCertification> certifications;

  factory CompanyPilot.fromJson(
    Map<String, dynamic> json,
  ) {
    final certificationData =
        json['certifications'] as List<dynamic>? ?? [];

    return CompanyPilot(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString(),
      companyName: json['company_name']?.toString(),
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(
              json['joined_at'].toString(),
            )
          : null,
      role:
          json['role']?.toString().toUpperCase() ?? 'PILOT',
      certifications: certificationData
          .map(
            (item) => PilotCertification.fromJson(
              Map<String, dynamic>.from(
                item as Map,
              ),
            ),
          )
          .toList(),
    );
  }

  String get displayName {
    final name = '$firstName $lastName'.trim();

    return name.isEmpty ? email : name;
  }

  String get initials {
    final first =
        firstName.trim().isNotEmpty
            ? firstName.trim()[0].toUpperCase()
            : '';

    final last =
        lastName.trim().isNotEmpty
            ? lastName.trim()[0].toUpperCase()
            : '';

    final result = '$first$last';

    return result.isEmpty ? '?' : result;
  }
}
