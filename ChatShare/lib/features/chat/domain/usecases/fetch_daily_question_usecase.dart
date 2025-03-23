import 'package:chatshare/features/chat/domain/entities/daily_question_entity.dart';
import 'package:chatshare/features/chat/domain/repositories/message_repository.dart';

class FetchDailyQuestionUseCase {
  final MessagesRepository messagesRepository;

  FetchDailyQuestionUseCase({required this.messagesRepository});

  Future<DailyQuestionEntity> call(String conversationId) async{
    return await messagesRepository.fetchDailyQuestion(conversationId);
  }
}