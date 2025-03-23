import 'package:chatshare/features/contacts/data/datasources/contacts_remote_data_source.dart';
import 'package:chatshare/features/contacts/domain/entities/contact_entity.dart';
import 'package:chatshare/features/contacts/domain/repositories/contacts_repository.dart';

class ContactsRepositoryImpl implements ContactsRepository {
  final ContactsRemoteDataSource remoteDatasource;

  ContactsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<void> addContact({required String email}) async {
    await remoteDatasource.addContact(email: email);
  }

  @override
  Future<List<ContactEntity>> fetchContacts() async {
    return await remoteDatasource.fetchContacts();
  }

  @override
  Future<List<ContactEntity>> getRecentContacts() async {
    return await remoteDatasource.fetchRecentContacts();
  }

}