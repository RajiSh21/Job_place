import 'package:dio/dio.dart';
import '../models/booking.dart';
import 'api_service.dart';

class BookingService {
  final _api = ApiService.instance;

  Future<BookingModel> createBooking({
    required String workerId,
    required String serviceType,
    required String description,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String address,
    String? addressDistrict,
    double? latitude,
    double? longitude,
    String paymentMethod = 'cash',
    double? amount,
    List<String> photoPaths = const [],
  }) async {
    final formData = FormData.fromMap({
      'workerId': workerId,
      'serviceType': serviceType,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String().split('T')[0],
      'scheduledTime': scheduledTime,
      'address': address,
      if (addressDistrict != null) 'addressDistrict': addressDistrict,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'paymentMethod': paymentMethod,
      if (amount != null) 'amount': amount,
    });

    for (final path in photoPaths) {
      formData.files.add(MapEntry('photos', await MultipartFile.fromFile(path)));
    }

    final response = await _api.client.post('/bookings', data: formData);
    return BookingModel.fromJson(
      (response.data as Map<String, dynamic>)['booking'] as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> listBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.client.get('/bookings', queryParameters: {
      if (status != null) 'status': status,
      'page': page,
      'limit': limit,
    });
    final data = response.data as Map<String, dynamic>;
    return {
      'bookings': (data['bookings'] as List<dynamic>)
          .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'total': data['total'] as int,
    };
  }

  Future<BookingModel> getBooking(String id) async {
    final response = await _api.client.get('/bookings/$id');
    return BookingModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BookingModel> acceptBooking(String id) async {
    final response = await _api.client.put('/bookings/$id/accept');
    return BookingModel.fromJson(
      (response.data as Map<String, dynamic>)['booking'] as Map<String, dynamic>,
    );
  }

  Future<BookingModel> declineBooking(String id) async {
    final response = await _api.client.put('/bookings/$id/decline');
    return BookingModel.fromJson(
      (response.data as Map<String, dynamic>)['booking'] as Map<String, dynamic>,
    );
  }

  Future<BookingModel> startBooking(String id) async {
    final response = await _api.client.put('/bookings/$id/start');
    return BookingModel.fromJson(
      (response.data as Map<String, dynamic>)['booking'] as Map<String, dynamic>,
    );
  }

  Future<BookingModel> completeBooking(String id) async {
    final response = await _api.client.put('/bookings/$id/complete');
    return BookingModel.fromJson(
      (response.data as Map<String, dynamic>)['booking'] as Map<String, dynamic>,
    );
  }

  Future<BookingModel> cancelBooking(String id, {String? reason}) async {
    final response = await _api.client.put(
      '/bookings/$id/cancel',
      data: {'reason': reason},
    );
    return BookingModel.fromJson(
      (response.data as Map<String, dynamic>)['booking'] as Map<String, dynamic>,
    );
  }
}
