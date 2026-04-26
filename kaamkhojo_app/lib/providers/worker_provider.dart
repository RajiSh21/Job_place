import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/worker.dart';
import '../services/worker_service.dart';

class WorkerProvider extends ChangeNotifier {
  final _service = WorkerService();

  List<WorkerModel> _workers = [];
  List<WorkerModel> _nearbyWorkers = [];
  List<WorkerModel> _topRatedWorkers = [];
  WorkerModel? _selectedWorker;
  Map<String, dynamic>? _dashboard;

  bool _loading = false;
  bool _loadingProfile = false;
  String? _error;
  int _total = 0;
  int _page = 1;
  bool _hasMore = true;

  // Filters
  String? filterCategory;
  String? filterDistrict;
  double? filterPriceMin;
  double? filterPriceMax;
  double? filterRatingMin;
  bool filterAvailableToday = false;
  String sortBy = 'rating';

  List<WorkerModel> get workers => _workers;
  List<WorkerModel> get nearbyWorkers => _nearbyWorkers;
  List<WorkerModel> get topRatedWorkers => _topRatedWorkers;
  WorkerModel? get selectedWorker => _selectedWorker;
  Map<String, dynamic>? get dashboard => _dashboard;
  bool get loading => _loading;
  bool get loadingProfile => _loadingProfile;
  String? get error => _error;
  int get total => _total;
  bool get hasMore => _hasMore;

  Future<void> loadNearbyWorkers({double? lat, double? lng, String? district}) async {
    try {
      final result = await _service.listWorkers(
        sortBy: lat != null ? 'nearest' : 'rating',
        lat: lat, lng: lng,
        district: district,
        limit: 10,
      );
      _nearbyWorkers = result['workers'] as List<WorkerModel>;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadTopRated({String? district}) async {
    try {
      final result = await _service.listWorkers(
        sortBy: 'rating',
        district: district,
        limit: 10,
        ratingMin: 3.5,
      );
      _topRatedWorkers = result['workers'] as List<WorkerModel>;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> searchWorkers({
    double? lat,
    double? lng,
    bool refresh = false,
  }) async {
    if (refresh) {
      _page = 1;
      _workers = [];
      _hasMore = true;
    }
    if (!_hasMore || _loading) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.listWorkers(
        category: filterCategory,
        district: filterDistrict,
        priceMin: filterPriceMin,
        priceMax: filterPriceMax,
        ratingMin: filterRatingMin,
        availableToday: filterAvailableToday,
        sortBy: sortBy,
        lat: lat,
        lng: lng,
        page: _page,
      );
      final newWorkers = result['workers'] as List<WorkerModel>;
      _workers = refresh ? newWorkers : [..._workers, ...newWorkers];
      _total = result['total'] as int;
      _hasMore = _workers.length < _total;
      _page++;
    } on DioException catch (e) {
      _error = _extractMessage(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkerProfile(String id) async {
    _loadingProfile = true;
    _error = null;
    notifyListeners();
    try {
      _selectedWorker = await _service.getWorker(id);
    } on DioException catch (e) {
      _error = _extractMessage(e);
    } finally {
      _loadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    try {
      _dashboard = await _service.getDashboard();
      notifyListeners();
    } catch (_) {}
  }

  void applyFilters({
    String? category,
    String? district,
    double? priceMin,
    double? priceMax,
    double? ratingMin,
    bool? availableToday,
    String? sort,
  }) {
    filterCategory = category;
    filterDistrict = district;
    filterPriceMin = priceMin;
    filterPriceMax = priceMax;
    filterRatingMin = ratingMin;
    filterAvailableToday = availableToday ?? false;
    sortBy = sort ?? 'rating';
  }

  void clearFilters() {
    filterCategory = null;
    filterDistrict = null;
    filterPriceMin = null;
    filterPriceMax = null;
    filterRatingMin = null;
    filterAvailableToday = false;
    sortBy = 'rating';
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'] as String;
    return 'डेटा लोड गर्न सकिएन।';
  }
}
