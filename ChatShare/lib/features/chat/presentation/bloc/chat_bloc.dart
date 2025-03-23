// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:chatshare/features/chat/domain/entities/daily_question_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chatshare/core/socket_service.dart';
import 'package:chatshare/features/chat/domain/entities/message_entity.dart';
import 'package:chatshare/features/chat/domain/usecases/fetch_daily_question_usecase.dart';
import 'package:chatshare/features/chat/domain/usecases/fetch_messages_use_case.dart';
import 'package:chatshare/features/chat/presentation/bloc/chat_event.dart';
import 'package:chatshare/features/chat/presentation/bloc/chat_state.dart';
import 'package:http/http.dart' as http;

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesUseCase fetchMessagesUseCase;
  final FetchDailyQuestionUseCase fetchDailyQuestionUseCase;
  final SocketService _socketService = SocketService();
  final List<MessageEntity> _messages = [];
  final _storage = FlutterSecureStorage();

  ChatBloc({required this.fetchMessagesUseCase, required this.fetchDailyQuestionUseCase}): super(ChatLoadingState()){
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<LoadDailyQuestionEvent>(_onLoadDailyQuestionEvent);
  }
Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
  emit(ChatLoadingState());

  try {
    final messages = await fetchMessagesUseCase(event.conversationId);

    _messages.clear();
    _messages.addAll(messages);
    
    print("Messages fetched: ${_messages.length}");

    emit(ChatLoadedState(List.from(_messages))); // ✅ Ensure UI updates before setting up socket
    
    // ✅ Set up real-time updates after loading messages
    _socketService.socket.off('newMessage');
    _socketService.socket.emit('joinConversation', event.conversationId);
    _socketService.socket.on('newMessage', (data) {
      print("New message received: $data");
      add(ReceiveMessageEvent(data));
    });

  } catch (error) {
    emit(ChatErrorState('Failed to load messages'));
  }
}


  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    String userId = await _storage.read(key: 'userId') ?? '';
    print('userId : $userId');

    final newMessage = {
      'conversationId': event.conversationId,
      'content': event.content,
      'senderId': userId,
    };
    _socketService.socket.emit('sendMessage', newMessage);
  }

  Future<void> _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) async {
  print("New message event received");
  print(event.message);

  final newMessage = MessageEntity(
    id: event.message['id'],
    conversationId: event.message['conversation_id'],
    senderId: event.message['sender_id'],
    content: event.message['content'],
    createdAt: event.message['created_at'],
    isImage: event.message['is_image'] ?? false,
  );

  if (!_messages.any((msg) => msg.id == newMessage.id)) {  // ✅ Prevent duplicates
    _messages.add(newMessage);
    emit(ChatLoadedState(List.from(_messages))); // ✅ Update UI
  }
}

Future<void> _onLoadDailyQuestionEvent(LoadDailyQuestionEvent event, Emitter<ChatState> emit) async {
  try {
    final response = await http.get(Uri.parse('http://192.168.33.126:4000/api/conversations/${event.conversationId}/daily-question'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dailyQuestion = DailyQuestionEntity(content: data['question']);
      
      final currentMessages = state is ChatLoadedState ? (state as ChatLoadedState).messages : _messages;

      emit(ChatDailyQuestionLoadedState(dailyQuestion));
      emit(ChatLoadedState(List.from(currentMessages))); // ✅ Preserve existing messages
    } else {
      emit(ChatErrorState('Failed to fetch AI message'));
    }
  } catch (error) {
    emit(ChatErrorState('Error loading AI message'));
  }
}


}