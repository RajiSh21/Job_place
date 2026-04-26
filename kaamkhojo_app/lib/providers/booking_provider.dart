import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final _service = BookingService();

  // Booking creation state (persisted across steps)
  String? draftWorkerId;
  String? draftWorkerName;
  String? draftServiceType;
  String? draftDescription;
  List<String> draftPhotoPaths = [];
  DateTime? draftDate;
  String? draftTime;
  String? draftAddress;
  String? draftAddressDistrict;
  double? draftLatitude;
  double? draftLongitude;
  String draftPaymentMethod = 'cash';
  double? draftAmount;

  List<BookingModel> _bookings = [];
  BookingModel? _currentBooking;
  bool _loading = false;
  String? _error;
  int _total = 0;
  bool _hasMore = true;
  int _page = 1;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get currentBooking => _currentBooking;
  bool get loading => _loading;
  String? get error => _error;
  int get total => _total;
  bool get hasMore => _hasMore;

  void setDraftWorker(String id, String name, String serviceType) {
    draftWorkerId = id;
    draftWorkerName = name;
    draftServiceType = serviceType;
    notifyListeners();
  }

  void updateDraftStep1({
    String? description,
    List<String>? photoPaths,
    DateTime? date,
    String? time,
    String? address,
    String? addressDistrict,
    double? latitude,
    double? longitude,
  }) {
    if (description != null) draftDescription = description;
    if (photoPaths != null) draftPhotoPaths = photoPaths;
    if (date != null) draftDate = date;
    if (time != null) draftTime = time;
    if (address != null) draftAddress = address;
    if (addressDistrict != null) draftAddressDistrict = addressDistrict;
    if (latitude != null) draftLatitude = latitude;
    if (longitude != null) draftLongitude = longitude;
    notifyListeners();
  }

  void updateDraftStep2({String? paymentMethod, double? amount}) {
    if (paymentMethod != null) draftPaymentMethod = paymentMethod;
    if (amount != null) draftAmount = amount;
    notifyListeners();
  }

  void clearDraft() {
    draftWorkerId = null;
    draftWorkerName = null;
    draftServiceType = null;
    draftDescription = null;
    draftPhotoPaths = [];
    draftDate = null;
    draftTime = null;
    draftAddress = null;
    draftAddressDistrict = null;
    draftLatitude = null;
    draftLongitude = null;
    draftPaymentMethod = 'cash';
    draftAmount = null;
    notifyListeners();
  }

  Future<BookingModel?> submitBooking() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final booking = await _service.createBooking(
        workerId: draftWorkerId!,
        serviceType: draftServiceType!,
        description: draftDescription ?? '',
        scheduledDate: draftDate!,
        scheduledTime: draftTime!,
        address: draftAddress!,
        addressDistrict: draftAddressDistrict,
        latitude: draftLatitude,
        longitude: draftLongitude,
        paymentMethod: draftPaymentMethod,
        amount: draftAmount,
        photoPaths: draftPhotoPaths,
      );
      _currentBooking = booking;
      clearDraft();
      _loading = false;
      notifyListeners();
      return booking;
    } on DioException catch (e) {
      _error = _extractMessage(e);
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadBookings({String? status, bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _bookings = [];
      _hasMore = true;
    }
    if (!_hasMore || _loading) return;
    _loading = true;
    notifyListeners();
    try {
      final result = await _service.listBookings(status: status, page: _page);
      final newBookings = result['bookings'] as List<BookingModel>;
      _bookings = refresh ? newBookings : [..._bookings, ...newBookings];
      _total = result['total'] as int;
      _hasMore = _bookings.length < _total;
      _page++;
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<void> acceptBooking(String id) async {
    await _updateBookingStatus(id, () => _service.acceptBooking(id));
  }

  Future<void> declineBooking(String id) async {
    await _updateBookingStatus(id, () => _service.declineBooking(id));
  }

  Future<void> startBooking(String id) async {
    await _updateBookingStatus(id, () => _service.startBooking(id));
  }

  Future<void> completeBooking(String id) async {
    await _updateBookingStatus(id, () => _service.completeBooking(id));
  }

  Future<void> cancelBooking(String id, {String? reason}) async {
    await _updateBookingStatus(id, () => _service.cancelBooking(id, reason: reason));
  }

  Future<void> _updateBookingStatus(String id, Future<BookingModel> Function() fn) async {
    _error = null;
    try {
      final updated = await fn();
      final idx = _bookings.indexWhere((b) => b.id == id);
      if (idx >= 0) {
        _bookings[idx] = updated;
        notifyListeners();
      }
    } on DioException catch (e) {
      _error = _extractMessage(e);
      notifyListeners();
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'] as String;
    return 'केही समस्या भयो।';
  }
}
