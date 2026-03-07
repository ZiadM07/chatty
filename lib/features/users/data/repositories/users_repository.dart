import 'package:Chatty/features/chats/data/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../auth/data/models/user_model.dart';
import '../data_sources/users_data_source.dart';

@lazySingleton
class UsersRepository {
  final UsersDataSource _dataSource;

  const UsersRepository(this._dataSource);

  Future<List<UserModel>> getUsers({
    required String currentUid,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) => _dataSource.getUsers(
    currentUid: currentUid,
    limit: limit,
    lastDocument: lastDocument,
  );

  Future<List<UserModel>> searchUsers({
    required String query,
    required String currentUid,
  }) => _dataSource.searchUsers(query: query, currentUid: currentUid);

  Future<UserModel?> getUserById({required String uid}) =>
      _dataSource.getUserById(uid: uid);

  Stream<UserModel?> watchUser({required String uid}) =>
      _dataSource.watchUser(uid: uid);

  Future<List<ChatModel>> getCommonGroups({
    required String currentUid,
    required String otherUid,
  }) => _dataSource.getCommonGroups(currentUid: currentUid, otherUid: otherUid);
}
