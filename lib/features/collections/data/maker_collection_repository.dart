import 'package:hive/hive.dart';

import 'maker_collection_model.dart';

abstract class MakerCollectionRepository {
  Future<List<MakerCollection>> getCollections();
  Future<MakerCollection?> getCollectionById(String id);
  Future<void> saveCollection(MakerCollection collection);
  Future<void> deleteCollection(String id);
}

class MakerCollectionRepositoryImpl implements MakerCollectionRepository {
  static const boxName = 'makerCollectionsBox';

  Future<Box<MakerCollection>> get _box async =>
      Hive.openBox<MakerCollection>(boxName);

  @override
  Future<void> deleteCollection(String id) async => (await _box).delete(id);

  @override
  Future<MakerCollection?> getCollectionById(String id) async =>
      (await _box).get(id);

  @override
  Future<List<MakerCollection>> getCollections() async {
    final collections = (await _box).values.toList(growable: false);
    collections.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return collections;
  }

  @override
  Future<void> saveCollection(MakerCollection collection) async =>
      (await _box).put(collection.id, collection);
}
