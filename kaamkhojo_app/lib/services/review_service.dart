import '../models/review.dart';
import 'api_service.dart';

class ReviewService {
  final _api = ApiService.instance;

  Future<ReviewModel> createReview({
    required String bookingId,
    required int rating,
    int? punctuality,
    int? quality,
    int? behavior,
    String? comment,
  }) async {
    final response = await _api.client.post('/reviews', data: {
      'bookingId': bookingId,
      'rating': rating,
      if (punctuality != null) 'punctuality': punctuality,
      if (quality != null) 'quality': quality,
      if (behavior != null) 'behavior': behavior,
      if (comment != null) 'comment': comment,
    });
    return ReviewModel.fromJson(
      (response.data as Map<String, dynamic>)['review'] as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> getWorkerReviews(
    String workerId, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _api.client.get(
      '/reviews/worker/$workerId',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    return {
      'reviews': (data['reviews'] as List<dynamic>)
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      'total': data['total'] as int,
    };
  }
}
