import 'package:get_it/get_it.dart';
import 'package:chatshare/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chatshare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chatshare/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatshare/features/auth/domain/usecases/login_use_case.dart';
import 'package:chatshare/features/auth/domain/usecases/register_use_case.dart';
import 'package:chatshare/features/chat/data/datasources/messages_remote_data_source.dart';
import 'package:chatshare/features/chat/data/repositories/message_repository_impl.dart';
import 'package:chatshare/features/chat/domain/repositories/message_repository.dart';
import 'package:chatshare/features/chat/domain/usecases/fetch_daily_question_usecase.dart';
import 'package:chatshare/features/chat/domain/usecases/fetch_messages_use_case.dart';
import 'package:chatshare/features/contacts/data/datasources/contacts_remote_data_source.dart';
import 'package:chatshare/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:chatshare/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:chatshare/features/contacts/domain/usecases/add_contact_usecase.dart';
import 'package:chatshare/features/contacts/domain/usecases/fetch_contacts_usecase.dart';
import 'package:chatshare/features/contacts/domain/usecases/fetch_recent_contacts_usecase.dart';
import 'package:chatshare/features/conversation/data/datasources/conversations_remote_data_source.dart';
import 'package:chatshare/features/conversation/data/repositories/conversations_repository_impl.dart';
import 'package:chatshare/features/conversation/domain/repositories/conversations_repository.dart';
import 'package:chatshare/features/conversation/domain/usecases/check_or_create_conversation_use_casse.dart';
import 'package:chatshare/features/conversation/domain/usecases/fetch_conversations_use_case.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  String serverUrl = 'http://192.168.222.126:4000'; // Default URL
  // if (serverUrl.isEmpty) {
  //   serverUrl = 'http://192.168.189.126:4000'; // Fallback
  // }
  final String baseUrl = serverUrl;

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(baseUrl: baseUrl),
  );
  sl.registerLazySingleton<ConversationsRemoteDataSource>(
    () => ConversationsRemoteDataSource(baseUrl: baseUrl),
  );
  sl.registerLazySingleton<MessagesRemoteDataSource>(
    () => MessagesRemoteDataSource(baseUrl: baseUrl),
  );
  sl.registerLazySingleton<ContactsRemoteDataSource>(
    () => ContactsRemoteDataSource(baseUrl: baseUrl),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemoteDataSource: sl()),
  );
  sl.registerLazySingleton<ConversationsRepository>(
    () => ConversationsRepositoryImpl(conversationRemoteDataSource: sl()),
  );
  sl.registerLazySingleton<MessagesRepository>(
    () => MessagesRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ContactsRepository>(
    () => ContactsRepositoryImpl(remoteDatasource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));
  sl.registerLazySingleton(() => FetchConversationsUseCase(sl()));
  sl.registerLazySingleton(
    () => FetchMessagesUseCase(messagesRepository: sl()),
  );
  sl.registerLazySingleton(
    () => FetchDailyQuestionUseCase(messagesRepository: sl()),
  );
  sl.registerLazySingleton(() => FetchContactUseCase(contactsRepository: sl()));
  sl.registerLazySingleton(() => AddContactUseCase(contactsRepository: sl()));
  sl.registerLazySingleton(
    () => CheckOrCreateConversationUseCase(conversationsRepository: sl()),
  );
  sl.registerLazySingleton(
    () => FetchRecentContactUseCase(contactsRepository: sl()),
  );
}
