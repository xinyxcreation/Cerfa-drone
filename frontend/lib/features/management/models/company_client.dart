class CompanyClient {
  const CompanyClient({
    required this.id,
    required this.name,
    this.customerReference,
    this.contactName,
    this.email,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.postalCode,
    this.city,
    this.country,
    this.notes,
    required this.isActive,
  });

  final String id;
  final String name;
  final String? customerReference;
  final String? contactName;
  final String? email;
  final String? phone;
  final String? addressLine1;
  final String? addressLine2;
  final String? postalCode;
  final String? city;
  final String? country;
  final String? notes;
  final bool isActive;

  factory CompanyClient.fromJson(Map<String, dynamic> json) {
    final rawActive = json['is_active'];

    return CompanyClient(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      customerReference: json['customer_reference']?.toString(),
      contactName: json['contact_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      addressLine1: json['address_line_1']?.toString(),
      addressLine2: json['address_line_2']?.toString(),
      postalCode: json['postal_code']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      notes: json['notes']?.toString(),
      isActive:
          rawActive == true ||
          rawActive == 1 ||
          rawActive?.toString() == '1' ||
          rawActive?.toString().toLowerCase() == 'true',
    );
  }
}
