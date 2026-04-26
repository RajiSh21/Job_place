class WorkerModel {
  final String id;
  final String userId;
  final String? name;
  final String? profilePhoto;
  final String? locationDistrict;
  final String? locationCity;
  final String? locationMunicipality;
  final int? locationWard;
  final List<String> skills;
  final String? bio;
  final double? hourlyRate;
  final double? fixedRate;
  final List<String> availabilityDays;
  final String? availabilityStartTime;
  final String? availabilityEndTime;
  final bool isVerified;
  final bool isFeatured;
  final double ratingAvg;
  final double ratingPunctuality;
  final double ratingQuality;
  final double ratingBehavior;
  final int totalJobs;
  final List<String> workPhotos;
  final int profileViews;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final DateTime? memberSince;
  final String? phone;

  const WorkerModel({
    required this.id,
    required this.userId,
    this.name,
    this.profilePhoto,
    this.locationDistrict,
    this.locationCity,
    this.locationMunicipality,
    this.locationWard,
    this.skills = const [],
    this.bio,
    this.hourlyRate,
    this.fixedRate,
    this.availabilityDays = const [],
    this.availabilityStartTime,
    this.availabilityEndTime,
    this.isVerified = false,
    this.isFeatured = false,
    this.ratingAvg = 0,
    this.ratingPunctuality = 0,
    this.ratingQuality = 0,
    this.ratingBehavior = 0,
    this.totalJobs = 0,
    this.workPhotos = const [],
    this.profileViews = 0,
    this.latitude,
    this.longitude,
    this.distance,
    this.memberSince,
    this.phone,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) => WorkerModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        name: json['name'] as String?,
        profilePhoto: json['profile_photo'] as String?,
        locationDistrict: json['location_district'] as String?,
        locationCity: json['location_city'] as String?,
        locationMunicipality: json['location_municipality'] as String?,
        locationWard: json['location_ward'] as int?,
        skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
        bio: json['bio'] as String?,
        hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
        fixedRate: (json['fixed_rate'] as num?)?.toDouble(),
        availabilityDays:
            (json['availability_days'] as List<dynamic>?)?.cast<String>() ?? [],
        availabilityStartTime: json['availability_start_time'] as String?,
        availabilityEndTime: json['availability_end_time'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
        isFeatured: json['is_featured'] as bool? ?? false,
        ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
        ratingPunctuality: (json['rating_punctuality'] as num?)?.toDouble() ?? 0,
        ratingQuality: (json['rating_quality'] as num?)?.toDouble() ?? 0,
        ratingBehavior: (json['rating_behavior'] as num?)?.toDouble() ?? 0,
        totalJobs: json['total_jobs'] as int? ?? 0,
        workPhotos: (json['work_photos'] as List<dynamic>?)?.cast<String>() ?? [],
        profileViews: json['profile_views'] as int? ?? 0,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        distance: (json['distance'] as num?)?.toDouble(),
        memberSince: json['member_since'] != null
            ? DateTime.tryParse(json['member_since'] as String)
            : null,
        phone: json['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'profile_photo': profilePhoto,
        'location_district': locationDistrict,
        'location_city': locationCity,
        'skills': skills,
        'hourly_rate': hourlyRate,
        'fixed_rate': fixedRate,
        'availability_days': availabilityDays,
        'is_verified': isVerified,
        'is_featured': isFeatured,
        'rating_avg': ratingAvg,
        'total_jobs': totalJobs,
      };

  String get displayPrice {
    if (hourlyRate != null) return 'रू ${hourlyRate!.toStringAsFixed(0)}/घण्टा';
    if (fixedRate != null) return 'रू ${fixedRate!.toStringAsFixed(0)}/काम';
    return 'मूल्य वार्ता';
  }

  String get displayDistance {
    if (distance == null) return '';
    if (distance! < 1) return '${(distance! * 1000).toStringAsFixed(0)} m';
    return '${distance!.toStringAsFixed(1)} km';
  }

  String get primarySkill => skills.isNotEmpty ? skills.first : '';
}
