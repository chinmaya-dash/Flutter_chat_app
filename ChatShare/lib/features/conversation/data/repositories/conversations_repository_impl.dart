import 'package:chatshare/features/conversation/data/datasources/conversations_remote_data_source.dart';
import 'package:chatshare/features/conversation/domain/entities/conversation_entity.dart';
import 'package:chatshare/features/conversation/domain/repositories/conversations_repository.dart';

class ConversationsRepositoryImpl implements ConversationsRepository {
  final ConversationsRemoteDataSource conversationRemoteDataSource;

  ConversationsRepositoryImpl({required this.conversationRemoteDataSource});

  @override
  Future<List<ConversationEntity>> fetchConversations() async {
    return await conversationRemoteDataSource.fetchConversations();
  }

  @override
  Future<String> checkOrCreateConversation({required String contactId}) async {
    return await conversationRemoteDataSource.checkOrCreateConversation(contactId: contactId);
  }
}