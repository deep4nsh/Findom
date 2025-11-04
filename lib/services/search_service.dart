import 'package:algolia/algolia.dart';
import 'package:findom/config/app_config.dart';

class SearchService {
  final Algolia _algolia = const Algolia.init(
    applicationId: AppConfig.algoliaAppId,
    apiKey: AppConfig.algoliaSearchApiKey,
  );

  Future<List<AlgoliaObjectSnapshot>> searchUsers(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final AlgoliaQuery algoliaQuery = _algolia.instance.index('users').query(query);
    final AlgoliaQuerySnapshot snapshot = await algoliaQuery.getObjects();

    return snapshot.hits;
  }
}
