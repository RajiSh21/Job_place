class MessageModel {
  final String id;
  final String bookingId;
  final String senderId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? senderName;
  final String? senderPhoto;

  const MessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    this.senderName,
    this.senderPhoto,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        bookingId: json['booking_id'] as String,
        senderId: json['sender_id'] as String,
        message: json['message'] as String,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        senderName: json['sender_name'] as String?,
        senderPhoto: json['sender_photo'] as String?,
      );
}
