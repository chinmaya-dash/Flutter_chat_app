import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chatshare/features/chat/data/models/daily_question_model.dart';
import 'package:chatshare/features/chat/data/models/message_model.dart';
import 'package:chatshare/features/chat/domain/entities/message_entity.dart';
import 'package:http/http.dart' as http;

class MessagesRemoteDataSource {
  final String baseUrl;
  final _storage = FlutterSecureStorage();

  MessagesRemoteDataSource({required this.baseUrl});

  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
      Uri.parse('$baseUrl/messages/$conversationId'),
      headers: {'Authorization': 'Bearer $token'}
    );
    if(response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Messages');
    }
  }

  Future<DailyQuestionModel> fetchDailyQuestion(String conversationId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
        Uri.parse('$baseUrl/conversations/$conversationId/daily-question'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if(response.statusCode == 200) {
      return DailyQuestionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch daily question');
    }
  }


}