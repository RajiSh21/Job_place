class ReviewModel {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String reviewedId;
  final int rating;
  final int? punctuality;
  final int? quality;
  final int? behavior;
  final String? comment;
  final DateTime createdAt;

  // Joined fields
  final String? reviewerName;
  final String? reviewerPhoto;
  final String? serviceType;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewedId,
    required this.rating,
    this.punctuality,
    this.quality,
    this.behavior,
    this.comment,
    required this.createdAt,
    this.reviewerName,
    this.reviewerPhoto,
    this.serviceType,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as String,
        bookingId: json['booking_id'] as String,
        reviewerId: json['reviewer_id'] as String,
        reviewedId: json['reviewed_id'] as String,
        rating: json['rating'] as int,
        punctuality: json['punctuality'] as int?,
        quality: json['quality'] as int?,
        behavior: json['behavior'] as int?,
        comment: json['comment'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        reviewerName: json['reviewer_name'] as String?,
        reviewerPhoto: json['reviewer_photo'] as String?,
        serviceType: json['service_type'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'rating': rating,
        'punctuality': punctuality,
        'quality': quality,
        'behavior': behavior,
        'comment': comment,
      };
}
