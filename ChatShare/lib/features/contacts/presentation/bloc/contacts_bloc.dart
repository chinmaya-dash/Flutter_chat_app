import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatshare/features/contacts/domain/usecases/add_contact_usecase.dart';
import 'package:chatshare/features/contacts/domain/usecases/fetch_contacts_usecase.dart';
import 'package:chatshare/features/contacts/domain/usecases/fetch_recent_contacts_usecase.dart';
import 'package:chatshare/features/contacts/presentation/bloc/contacts_event.dart';
import 'package:chatshare/features/contacts/presentation/bloc/contacts_state.dart';
import 'package:chatshare/features/conversation/domain/usecases/check_or_create_conversation_use_casse.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final FetchContactUseCase fetchContactsUseCase;
  final AddContactUseCase addContactUseCase;
  final CheckOrCreateConversationUseCase checkOrCreateConversationUseCase;
  final FetchRecentContactUseCase fetchRecentContactUseCase;


  ContactsBloc({
    required this.fetchContactsUseCase,
    required this.addContactUseCase,
    required this.checkOrCreateConversationUseCase,
    required this.fetchRecentContactUseCase
  }):

  super(ContactsInitial()){
    on<FetchContacts>(_onFetchContacts);
    on<AddContact>(_onAddContact);
    on<CheckOrCreateConversation>(_onCheckOrCreateConversation);
    on<LoadRecentContacts>(_onLoadRecentContactsEvent);
  }

  Future<void> _onLoadRecentContactsEvent(LoadRecentContacts event, Emitter<ContactsState> emit) async {

    emit(ContactsLoading());
    try{
      final recentContacts = await fetchRecentContactUseCase();
      emit(RecentContactsLoaded(recentContacts));
    } catch (error) {
      emit(ContactsError('Failed to load recent contacts'));
    }
  }


  Future<void> _onFetchContacts(FetchContacts event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try{
      final contacts = await fetchContactsUseCase();
      emit(ContactsLoaded(contacts));
    } catch(error) {
      emit(ContactsError('Failed to fetch contacts'));
    }
  }

  Future<void> _onAddContact(AddContact event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try{
      await addContactUseCase(email: event.email);
      emit(ContactAdded());
      add(FetchContacts());
    } catch(error) {
      emit(ContactsError('Failed to fetch contacts'));
    }
  }

  Future<void> _onCheckOrCreateConversation(CheckOrCreateConversation event, Emitter<ContactsState> emit) async {
    try{
      emit(ContactsLoading());
      final conversationId = await checkOrCreateConversationUseCase(contactId: event.contactId);
      emit(ConversationReady(conversationId: conversationId, contact: event.contact));
    } catch(error) {
      emit(ContactsError('Failed to start conversation'));
    }
  }

}