import 'package:chatshare/features/contacts/domain/entities/contact_entity.dart';
import 'package:chatshare/features/contacts/domain/repositories/contacts_repository.dart';

class FetchRecentContactUseCase {
  final ContactsRepository contactsRepository;

  FetchRecentContactUseCase({required this.contactsRepository});

  Future<List<ContactEntity>> call() async {
    return await contactsRepository.getRecentContacts();
  }
}