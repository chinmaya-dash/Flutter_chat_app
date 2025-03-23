import 'package:chatshare/features/chat/data/datasources/messages_remote_data_source.dart';
import 'package:chatshare/features/chat/domain/entities/daily_question_entity.dart';
import 'package:chatshare/features/chat/domain/entities/message_entity.dart';
import 'package:chatshare/features/chat/domain/repositories/message_repository.dart';

class MessagesRepositoryImpl implements MessagesRepository{
  final MessagesRemoteDataSource remoteDataSource;

  MessagesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    return await remoteDataSource.fetchMessages(conversationId);
  }

  @override
  Future<void> sendMessage(MessageEntity message) {
    throw UnimplementedError();
  }

  @override
  Future<DailyQuestionEntity> fetchDailyQuestion(String conversationId) async {
    return await remoteDataSource.fetchDailyQuestion(conversationId);
  }

}