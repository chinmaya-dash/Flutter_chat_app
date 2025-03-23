abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String conversationId;
  LoadMessagesEvent(this.conversationId);
}

class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String content;
  final bool isImage; // ✅ Added isImage flag

  SendMessageEvent(this.conversationId, this.content, {this.isImage = false});
}

class ReceiveMessageEvent extends ChatEvent {
  final Map<String, dynamic> message;
  ReceiveMessageEvent(this.message);
}

class LoadDailyQuestionEvent extends ChatEvent {
  final String conversationId;

  LoadDailyQuestionEvent(this.conversationId);
}