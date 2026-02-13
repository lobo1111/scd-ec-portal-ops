/// Admin company as returned by the API and held in local store.
class AdminCompany {
  const AdminCompany({
    required this.id,
    required this.legalName,
    required this.contactEmail,
    this.address,
    this.communityCount = 0,
    this.adminUserCount = 0,
  });

  final String id;
  final String legalName;
  final String contactEmail;
  final String? address;
  final int communityCount;
  final int adminUserCount;

  factory AdminCompany.fromJson(Map<String, dynamic> json) {
    return AdminCompany(
      id: json['id'] as String? ?? '',
      legalName: json['legalName'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      address: json['address'] as String?,
      communityCount: (json['communityCount'] as num?)?.toInt() ?? 0,
      adminUserCount: (json['adminUserCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'legalName': legalName,
      'contactEmail': contactEmail,
      if (address != null) 'address': address,
      'communityCount': communityCount,
      'adminUserCount': adminUserCount,
    };
  }

  AdminCompany copyWith({
    String? id,
    String? legalName,
    String? contactEmail,
    String? address,
    int? communityCount,
    int? adminUserCount,
  }) {
    return AdminCompany(
      id: id ?? this.id,
      legalName: legalName ?? this.legalName,
      contactEmail: contactEmail ?? this.contactEmail,
      address: address ?? this.address,
      communityCount: communityCount ?? this.communityCount,
      adminUserCount: adminUserCount ?? this.adminUserCount,
    );
  }
}
