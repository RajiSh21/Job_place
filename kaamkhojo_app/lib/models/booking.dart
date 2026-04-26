class BookingModel {
  final String id;
  final String customerId;
  final String workerId;
  final String serviceType;
  final String? description;
  final List<String> jobPhotos;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String address;
  final String? addressDistrict;
  final double? latitude;
  final double? longitude;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double? amount;
  final double? commission;
  final String? cancellationReason;
  final DateTime createdAt;

  // Joined fields
  final String? customerName;
  final String? customerPhone;
  final String? customerPhoto;
  final String? workerName;
  final String? workerPhone;
  final String? workerPhoto;
  final List<String>? workerSkills;
  final double? workerHourlyRate;
  final double? workerFixedRate;
  final double? workerRating;
  final String? workerProfileId;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.workerId,
    required this.serviceType,
    this.description,
    this.jobPhotos = const [],
    required this.scheduledDate,
    required this.scheduledTime,
    required this.address,
    this.addressDistrict,
    this.latitude,
    this.longitude,
    required this.status,
    this.paymentMethod = 'cash',
    this.paymentStatus = 'pending',
    this.amount,
    this.commission,
    this.cancellationReason,
    required this.createdAt,
    this.customerName,
    this.customerPhone,
    this.customerPhoto,
    this.workerName,
    this.workerPhone,
    this.workerPhoto,
    this.workerSkills,
    this.workerHourlyRate,
    this.workerFixedRate,
    this.workerRating,
    this.workerProfileId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'] as String,
        customerId: json['customer_id'] as String,
        workerId: json['worker_id'] as String,
        serviceType: json['service_type'] as String,
        description: json['description'] as String?,
        jobPhotos: (json['job_photos'] as List<dynamic>?)?.cast<String>() ?? [],
        scheduledDate: DateTime.parse(json['scheduled_date'] as String),
        scheduledTime: json['scheduled_time'] as String,
        address: json['address'] as String,
        addressDistrict: json['address_district'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        status: json['status'] as String? ?? 'pending',
        paymentMethod: json['payment_method'] as String? ?? 'cash',
        paymentStatus: json['payment_status'] as String? ?? 'pending',
        amount: (json['amount'] as num?)?.toDouble(),
        commission: (json['commission'] as num?)?.toDouble(),
        cancellationReason: json['cancellation_reason'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        customerName: json['customer_name'] as String?,
        customerPhone: json['customer_phone'] as String?,
        customerPhoto: json['customer_photo'] as String?,
        workerName: json['worker_name'] as String?,
        workerPhone: json['worker_phone'] as String?,
        workerPhoto: json['worker_photo'] as String?,
        workerSkills: (json['skills'] as List<dynamic>?)?.cast<String>(),
        workerHourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
        workerFixedRate: (json['fixed_rate'] as num?)?.toDouble(),
        workerRating: (json['rating_avg'] as num?)?.toDouble(),
        workerProfileId: json['worker_profile_id'] as String?,
      );

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isDeclined => status == 'declined';
  bool get isActive => isAccepted || isInProgress;
}
