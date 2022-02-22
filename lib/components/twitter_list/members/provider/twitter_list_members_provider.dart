import 'package:built_collection/built_collection.dart';
import 'package:dart_twitter_api/twitter_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harpy/api/api.dart';
import 'package:harpy/components/components.dart';

final twitterListMembersProvider = StateNotifierProvider.autoDispose.family<
    TwitterListMembersNotifier, PaginatedState<BuiltList<UserData>>, String>(
  (ref, listId) => TwitterListMembersNotifier(
    twitterApi: ref.watch(twitterApiProvider),
    listId: listId,
  ),
  name: 'TwitterListMembersProvider',
);

class TwitterListMembersNotifier extends PaginatedUsersNotifier {
  TwitterListMembersNotifier({
    required TwitterApi twitterApi,
    required String listId,
  })  : _twitterApi = twitterApi,
        _listId = listId,
        super(const PaginatedState.loading()) {
    loadInitial();
  }

  final TwitterApi _twitterApi;
  final String _listId;

  @override
  Future<PaginatedUsers> request([int? cursor]) {
    return _twitterApi.listsService.members(
      listId: _listId,
      cursor: cursor?.toString(),
      skipStatus: true,
      count: 200,
    );
  }
}
