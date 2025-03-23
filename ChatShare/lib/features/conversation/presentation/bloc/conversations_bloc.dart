// ignore_for_file: avoid_print

import 'package:chatshare/core/socket_service.dart';
// import 'package:chatshare/features/contacts/domain/usecases/fetch_recent_contacts_usecase.dart';
import 'package:chatshare/features/conversation/domain/usecases/fetch_conversations_use_case.dart';
import 'package:chatshare/features/conversation/presentation/bloc/conversations_event.dart';
import 'package:chatshare/features/conversation/presentation/bloc/conversations_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final FetchConversationsUseCase fetchConversationsUseCase;
  final SocketService _socketService = SocketService();

  ConversationsBloc({required this.fetchConversationsUseCase}) : super(ConversationsInitial()) {
    _initializeSocketListeners();
    on<FetchConversations>(_onFetchConversations);
  }

  void _initializeSocketListeners(){
    try{
      _socketService.socket.on('conversationUpdated', _onConversationUpdated);
    }catch(e){
      print("Error initializing socket listeners : $e");
    }
  }

  Future<void> _onFetchConversations(FetchConversations event, Emitter<ConversationsState> emit) async {

    emit(ConversationsLoading());
    try{
      final conversations = await fetchConversationsUseCase();
      print(conversations);
      emit(ConversationsLoaded(conversations));
    } catch (error) {
      emit(ConversationsError('Failed to load conversations'));
    }
  }

  void _onConversationUpdated(data){
    add(FetchConversations());
  }

}