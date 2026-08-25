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

  factory CompanyPilot.fromJson(
    Map<String, dynamic> json,
  ) {
    return CompanyPilot(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      joinedAt: json['joined_at'] != null
      ? DateTime.tryParse(
        json['joined_at'].toString(),
      )
      : null,
      role: json['role']?.toString().toUpperCase() ?? 'PILOT',
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
