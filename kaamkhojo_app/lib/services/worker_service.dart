import 'package:dio/dio.dart';
import '../models/worker.dart';
import 'api_service.dart';

class WorkerService {
  final _api = ApiService.instance;

  Future<Map<String, dynamic>> listWorkers({
    String? category,
    String? district,
    double? priceMin,
    double? priceMax,
    double? ratingMin,
    bool availableToday = false,
    String sortBy = 'rating',
    double? lat,
    double? lng,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.client.get('/workers', queryParameters: {
      if (category != null) 'category': category,
      if (district != null) 'district': district,
      if (priceMin != null) 'priceMin': priceMin,
      if (priceMax != null) 'priceMax': priceMax,
      if (ratingMin != null) 'ratingMin': ratingMin,
      if (availableToday) 'availableToday': 'true',
      'sortBy': sortBy,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'page': page,
      'limit': limit,
    });
    final data = response.data as Map<String, dynamic>;
    return {
      'workers': (data['workers'] as List<dynamic>)
          .map((e) => WorkerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'total': data['total'] as int,
      'page': data['page'] as int,
    };
  }

  Future<WorkerModel> getWorker(String id) async {
    final response = await _api.client.get('/workers/$id');
    return WorkerModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _api.client.get('/workers/dashboard');
    return response.data as Map<String, dynamic>;
  }

  Future<void> registerWorker(Map<String, dynamic> data) async {
    await _api.client.post('/workers/register', data: data);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _api.client.put('/workers/profile', data: data);
  }

  Future<void> uploadWorkPhotos(List<String> filePaths) async {
    final formData = FormData();
    for (final path in filePaths) {
      formData.files.add(MapEntry('photos', await MultipartFile.fromFile(path)));
    }
    await _api.client.post('/workers/work-photos', data: formData);
  }
}
