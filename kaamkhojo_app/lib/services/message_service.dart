import '../models/message.dart';
import 'api_service.dart';

class MessageService {
  final _api = ApiService.instance;

  Future<List<MessageModel>> getMessages(String bookingId, {int page = 1}) async {
    final response = await _api.client.get(
      '/messages/$bookingId',
      queryParameters: {'page': page, 'limit': 50},
    );
    final data = response.data as Map<String, dynamic>;
    return (data['messages'] as List<dynamic>)
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageModel> sendMessage(String bookingId, String message) async {
    final response = await _api.client.post(
      '/messages/$bookingId',
      data: {'message': message},
    );
    return MessageModel.fromJson(
      (response.data as Map<String, dynamic>)['message'] as Map<String, dynamic>,
    );
  }
}
