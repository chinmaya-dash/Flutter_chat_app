import 'package:chatshare/features/chat/domain/entities/daily_question_entity.dart';
import 'package:chatshare/features/chat/domain/entities/message_entity.dart';

abstract class ChatState{}

class ChatLoadingState extends ChatState{}

class ChatLoadedState extends ChatState {
  final List<MessageEntity> messages;

  ChatLoadedState(this.messages);
}


class ChatErrorState extends ChatState{
  final String message;
  ChatErrorState(this.message);
}

class ChatDailyQuestionLoadedState extends ChatState{
  final DailyQuestionEntity dailyQuestion;
  ChatDailyQuestionLoadedState(this.dailyQuestion);
}

