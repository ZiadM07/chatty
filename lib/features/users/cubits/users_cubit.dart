import 'package:chatty/core/constants/exports.dart';
import 'package:chatty/features/users/cubits/users_state.dart';
import 'package:chatty/features/users/data/data_sources/users_data_source.dart';
import 'package:chatty/features/users/data/repositories/users_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@injectable
class UsersCubit extends Cubit<UsersState> {
  final UsersRepository _repository;

  static const int _pageSize = 20;
  DocumentSnapshot? _lastDocument;

  UsersCubit(this._repository) : super(const UsersState());

  // ─── Load First Page ──────────────────────────────────────────────────────

  Future<void> loadUsers({required String currentUid}) async {
    // Reset pagination
    _lastDocument = null;

    emit(
      state.copyWith(
        usersState: const AppState(status: StateStatus.loading),
        users: [],
        hasMore: true,
      ),
    );

    try {
      final users = await _repository.getUsers(
        currentUid: currentUid,
        limit: _pageSize,
      );

      _lastDocument = users.isNotEmpty
          ? await _getLastSnapshot(users.last.uid)
          : null;

      emit(
        state.copyWith(
          usersState: AppState(status: StateStatus.success, data: users),
          users: users,
          hasMore: users.length == _pageSize,
        ),
      );
    } on UsersException catch (e) {
      emit(
        state.copyWith(
          usersState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          usersState: const AppState(
            status: StateStatus.error,
            message: 'Failed to load users.',
          ),
        ),
      );
    }
  }

  // ─── Load Next Page ───────────────────────────────────────────────────────

  Future<void> loadMore({required String currentUid}) async {
    if (!state.hasMore) return;
    if (state.usersState.status == StateStatus.loading) return;
    if (state.isSearching) return;

    emit(
      state.copyWith(usersState: const AppState(status: StateStatus.loading)),
    );

    try {
      final more = await _repository.getUsers(
        currentUid: currentUid,
        limit: _pageSize,
        lastDocument: _lastDocument,
      );

      if (more.isNotEmpty) {
        _lastDocument = await _getLastSnapshot(more.last.uid);
      }

      final combined = [...state.users, ...more];

      emit(
        state.copyWith(
          usersState: AppState(status: StateStatus.success, data: combined),
          users: combined,
          hasMore: more.length == _pageSize,
        ),
      );
    } on UsersException catch (e) {
      emit(
        state.copyWith(
          usersState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          usersState: const AppState(
            status: StateStatus.error,
            message: 'Failed to load more users.',
          ),
        ),
      );
    }
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  Future<void> search({
    required String query,
    required String currentUid,
  }) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      // Back to full list
      emit(state.copyWith(isSearching: false, searchQuery: ''));
      await loadUsers(currentUid: currentUid);
      return;
    }

    emit(
      state.copyWith(
        isSearching: true,
        searchQuery: trimmed,
        usersState: const AppState(status: StateStatus.loading),
      ),
    );

    try {
      final results = await _repository.searchUsers(
        query: trimmed,
        currentUid: currentUid,
      );

      emit(
        state.copyWith(
          usersState: AppState(status: StateStatus.success, data: results),
          users: results,
          hasMore: false, // no pagination during search
        ),
      );
    } on UsersException catch (e) {
      emit(
        state.copyWith(
          usersState: AppState(status: StateStatus.error, message: e.message),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          usersState: const AppState(
            status: StateStatus.error,
            message: 'Search failed.',
          ),
        ),
      );
    }
  }

  void clearSearch({required String currentUid}) {
    emit(state.copyWith(isSearching: false, searchQuery: ''));
    loadUsers(currentUid: currentUid);
  }

  // ─── Helper: get Firestore DocumentSnapshot for pagination cursor ─────────

  Future<DocumentSnapshot?> _getLastSnapshot(String uid) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
    } catch (_) {
      return null;
    }
  }
}
