import 'package:chatshare/features/chat/domain/entities/message_entity.dart';
import 'package:chatshare/features/chat/domain/repositories/message_repository.dart';

class FetchMessagesUseCase {
  final MessagesRepository messagesRepository;

  FetchMessagesUseCase({required this.messagesRepository});

  Future<List<MessageEntity>> call(String conversationId) async{
    return await messagesRepository.fetchMessages(conversationId);
  }
}