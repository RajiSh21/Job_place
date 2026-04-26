class UserModel {
  final String id;
  final String? name;
  final String phone;
  final String? email;
  final String role;
  final String? locationDistrict;
  final String? locationCity;
  final String? locationMunicipality;
  final int? locationWard;
  final String? profilePhoto;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    this.name,
    required this.phone,
    this.email,
    required this.role,
    this.locationDistrict,
    this.locationCity,
    this.locationMunicipality,
    this.locationWard,
    this.profilePhoto,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String?,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        role: json['role'] as String? ?? 'customer',
        locationDistrict: json['location_district'] as String?,
        locationCity: json['location_city'] as String?,
        locationMunicipality: json['location_municipality'] as String?,
        locationWard: json['location_ward'] as int?,
        profilePhoto: json['profile_photo'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'location_district': locationDistrict,
        'location_city': locationCity,
        'location_municipality': locationMunicipality,
        'location_ward': locationWard,
        'profile_photo': profilePhoto,
        'created_at': createdAt?.toIso8601String(),
      };

  bool get isWorker => role == 'worker';
  bool get isCustomer => role == 'customer';
  bool get isAdmin => role == 'admin';
  bool get hasName => name != null && name!.isNotEmpty;

  UserModel copyWith({
    String? name,
    String? email,
    String? locationDistrict,
    String? locationCity,
    String? locationMunicipality,
    int? locationWard,
    String? profilePhoto,
    String? role,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        phone: phone,
        email: email ?? this.email,
        role: role ?? this.role,
        locationDistrict: locationDistrict ?? this.locationDistrict,
        locationCity: locationCity ?? this.locationCity,
        locationMunicipality: locationMunicipality ?? this.locationMunicipality,
        locationWard: locationWard ?? this.locationWard,
        profilePhoto: profilePhoto ?? this.profilePhoto,
        createdAt: createdAt,
      );
}
