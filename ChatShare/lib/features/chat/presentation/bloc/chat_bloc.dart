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
  String? _currentConversationId; // ✅ Track the active conversation

  ChatBloc({
    required this.fetchMessagesUseCase,
    required this.fetchDailyQuestionUseCase,
  }) : super(ChatLoadingState()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<LoadDailyQuestionEvent>(_onLoadDailyQuestionEvent);
    on<UpdateMessageStatusEvent>(
      _onUpdateMessageStatus,
    ); // ✅ Correctly registered
      // ✅ Prevent duplicate listeners when ChatBloc is created
  _socketService.socket.off('newMessage');
  _socketService.socket.off('updateMessageStatus');

   // ✅ Listen for real-time messages globally
  _socketService.socket.on('newMessage', (data) {
    print("📩 New message received: $data");
    add(ReceiveMessageEvent(data));
  });


  _socketService.socket.on('updateMessageStatus', (data) {
    add(UpdateMessageStatusEvent(data['messageId'], data['status']));
  });

  }

  // ✅ Load messages and mark unread as "read"
Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
  if (_currentConversationId != event.conversationId) {
    _messages.clear(); // ✅ Clear only when switching conversations
  }

  try {
    _currentConversationId = event.conversationId;
    final messages = await fetchMessagesUseCase(event.conversationId);

    for (var message in messages) {
      if (message.status == 'delivered') {
        _socketService.socket.emit('updateMessageStatus', {
          'messageId': message.id,
          'status': 'read',
          'conversationId': event.conversationId,
        });
      }
    }

    // ✅ Instead of _messages = messages (which causes an error), use .clear() and .addAll()
    if (_messages.isEmpty || messages.length > _messages.length) {
      _messages.clear();
      _messages.addAll(messages);
      emit(ChatLoadedState(List.from(_messages))); 
    }

    print("✅ Messages fetched: ${_messages.length}");
  } catch (error) {
    print("❌ Error loading messages: $error");
    emit(ChatErrorState('Failed to load messages'));
  }

  // ✅ Ensure socket listeners are added only once
  _socketService.socket.off('newMessage');
  _socketService.socket.off('updateMessageStatus');

  _socketService.socket.on('newMessage', (data) {
    print("📩 New message received: $data");
    add(ReceiveMessageEvent(data));
  });

  _socketService.socket.on('updateMessageStatus', (data) {
    add(UpdateMessageStatusEvent(data['messageId'], data['status']));
  });
}


  // ✅ Handle updating message status
void _onUpdateMessageStatus(
  UpdateMessageStatusEvent event,
  Emitter<ChatState> emit,
) {
  int index = _messages.indexWhere((msg) => msg.id == event.messageId);
  if (index != -1) {
    _messages[index] = _messages[index].copyWith(status: event.status);
    
    // ✅ Ensure UI updates
    emit(ChatLoadedState(List.from(_messages))); 
  }
}



  // ✅ Handle sending messages
  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
  String userId = await _storage.read(key: 'userId') ?? '';
  print('userId : $userId');

  // ✅ Create a temporary message with "sending" status
  final tempMessage = MessageEntity(
    id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
    conversationId: event.conversationId,
    senderId: userId,
    content: event.content,
    createdAt: DateTime.now().toIso8601String(),
    isImage: event.isImage,
    status: 'sending', // 🔴 Initially marked as "sending"
  );

  // ✅ Add the message to the chat immediately
  _messages.add(tempMessage);
  emit(ChatLoadedState(List.from(_messages))); // ✅ UI updates immediately

  // ✅ Send message to the server
  final newMessage = {
    'conversationId': event.conversationId,
    'content': event.content,
    'senderId': userId,
  };

  _socketService.socket.emit('sendMessage', newMessage);

  // ✅ Restore "messageSent" listener
  _socketService.socket.on('messageSent', (data) {
    print("🟢 Server response: $data");

    if (data != null && data['id'] != null) {
      // ✅ Find the message and update its ID and status
      int index = _messages.indexWhere((msg) => msg.id == tempMessage.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          id: data['id'], // ✅ Replace temp ID with real ID
          status: 'sent', // ✅ Immediately mark as "sent"
        );

        emit(ChatLoadedState(List.from(_messages))); // ✅ Force UI update
      }
    }
  });
}


  // ✅ Handle receiving messages
Future<void> _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) async {
  print("📩 New message event received");
  print(event.message);

  final newMessage = MessageEntity(
    id: event.message['id'],
    conversationId: event.message['conversation_id'],
    senderId: event.message['sender_id'],
    content: event.message['content'],
    createdAt: event.message['created_at'],
    isImage: event.message['is_image'] ?? false,
    status: event.message['status'] ?? 'delivered',
  );

  // ✅ Ensure message is not duplicated
  if (!_messages.any((msg) => msg.id == newMessage.id)) {
    _messages.add(newMessage);
  }

  emit(ChatLoadedState(List.from(_messages)));
}








  // ✅ Handle loading daily question
  Future<void> _onLoadDailyQuestionEvent(
    LoadDailyQuestionEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.222.126:4000/api/conversations/${event.conversationId}/daily-question',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dailyQuestion = DailyQuestionEntity(content: data['question']);

        // ✅ Ensure no duplicate AI message is added
        final chatState =
            state is ChatLoadedState
                ? state as ChatLoadedState
                : ChatLoadedState([]);
        if (chatState.messages.any(
          (msg) => msg.content == dailyQuestion.content,
        )) {
          print("Duplicate AI message detected, skipping...");
          return;
        }

        // ✅ Preserve previous messages while adding the AI question
        final updatedMessages = List<MessageEntity>.from(chatState.messages)
          ..add(
            MessageEntity(
              id: "ai_${DateTime.now().millisecondsSinceEpoch}",
              conversationId: event.conversationId,
              senderId: "bot",
              content: dailyQuestion.content,
              createdAt: DateTime.now().toIso8601String(),
              isImage: false,
              status: 'delivered', // ✅ Default AI messages as delivered
            ),
          );

        emit(ChatLoadedState(updatedMessages));
      } else {
        emit(ChatErrorState('Failed to fetch AI message'));
      }
    } catch (error) {
      emit(ChatErrorState('Error loading AI message'));
    }
  }
}

// ✅ Fix `UpdateMessageStatusEvent`
class UpdateMessageStatusEvent extends ChatEvent {
  final String messageId;
  final String status;

  UpdateMessageStatusEvent(this.messageId, this.status);
}
