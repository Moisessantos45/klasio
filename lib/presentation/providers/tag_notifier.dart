import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klasio/data/datasources/tag_datasource.dart';
import 'package:klasio/domain/entities/tag.dart';

final tagDatasourceProvider = Provider<TagDatasource>((ref) => TagDatasource());

final tagNotifierProvider = AsyncNotifierProvider<TagNotifier, List<Tag>>(
  TagNotifier.new,
);

class TagNotifier extends AsyncNotifier<List<Tag>> {
  late final TagDatasource _ds;

  @override
  Future<List<Tag>> build() async {
    _ds = ref.read(tagDatasourceProvider);
    return _ds.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ds.getAll());
  }

  Future<void> addTag(String name) async {
    final tag = Tag(name: name, createdAt: DateTime.now(), id: 0);
    final inserted = await _ds.insert(tag);
    state = state.whenData((list) => [...list, inserted]);
  }
}
