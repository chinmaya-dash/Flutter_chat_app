import 'package:chatshare/features/contacts/domain/entities/contact_entity.dart';
import 'package:chatshare/features/contacts/domain/repositories/contacts_repository.dart';

class FetchContactUseCase {
  final ContactsRepository contactsRepository;

  FetchContactUseCase({required this.contactsRepository});
  
  Future<List<ContactEntity>> call() async {
    return await contactsRepository.fetchContacts();
  }
}