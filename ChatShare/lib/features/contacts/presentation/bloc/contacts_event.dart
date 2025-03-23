import 'package:chatshare/features/contacts/domain/entities/contact_entity.dart';
// import 'package:wori_app/features/conversation/domain/entities/conversation_entity.dart';

abstract class ContactsEvent {}

class FetchContacts extends ContactsEvent {}

class CheckOrCreateConversation extends ContactsEvent {
  final String contactId;
  final ContactEntity contact;

  CheckOrCreateConversation(this.contactId, this.contact);
}

class AddContact extends ContactsEvent {
  final String email;

  AddContact(this.email);
}

class LoadRecentContacts extends ContactsEvent {}
