import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klasio/data/datasources/folder_datasource.dart';
import 'package:klasio/domain/entities/folder.dart';
import 'package:klasio/domain/entities/pagination.dart';

final folderDatasourceProvider = Provider<FolderDatasource>(
  (ref) => FolderDatasource(),
);

final folderNotifierProvider =
    AsyncNotifierProvider<FolderNotifier, FolderList>(FolderNotifier.new);

class FolderNotifier extends AsyncNotifier<FolderList> {
  late final FolderDatasource _ds;

  @override
  Future<FolderList> build() async {
    _ds = ref.read(folderDatasourceProvider);

    final result = await _ds.getAll();

    return FolderList(
      folders: result.folders,
      pagination: Pagination(
        currentPage: 1,
        pageSize: 10,
        totalPages: result.total == 0 ? 1 : (result.total / 10).ceil(),
        total: result.total,
      ),
    );
  }

  Future<void> refresh() async {
    await getAll(page: 1, pageSize: 10, query: '');
  }

  Future<void> getAll({
    int page = 1,
    int pageSize = 10,
    String query = '',
  }) async {
    if (page <= 0) page = 1;
    if (pageSize <= 0) pageSize = 10;

    final offset = (page - 1) * pageSize;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _ds.getAll(
        limit: pageSize,
        offset: offset,
        query: query,
      );

      final totalPages = result.total == 0
          ? 1
          : (result.total / pageSize).ceil();

      return FolderList(
        folders: result.folders,
        pagination: Pagination(
          currentPage: page,
          pageSize: pageSize,
          totalPages: totalPages,
          total: result.total,
          query: query,
        ),
      );
    });
  }

  Future<Folder?> getById(int id) async {
    return await _ds.getById(id);
  }

  Future<void> addFolder(String name, int indexIcon, int indexColor) async {
    final folder = Folder(
      name: name,
      indexIcon: indexIcon,
      indexColor: indexColor,
      createdAt: DateTime.now(),
    );
    final inserted = await _ds.insert(folder);

    state = state.whenData(
      (current) => current.copyWith(
        folders: [inserted, ...current.folders],
        pagination: current.pagination.copyWith(
          total: current.pagination.total + 1,
        ),
      ),
    );
  }

  Future<void> removeFolder(int id) async {
    await _ds.delete(id);

    state = state.whenData(
      (current) => current.copyWith(
        folders: current.folders.where((f) => f.id != id).toList(),
        pagination: current.pagination.copyWith(
          total: current.pagination.total - 1,
        ),
      ),
    );
  }

  Future<void> updateFolder(
    int id,
    String name,
    int indexIcon,
    int indexColor,
  ) async {
    final folder = Folder(
      id: id,
      name: name,
      indexIcon: indexIcon,
      indexColor: indexColor,
      createdAt: DateTime.now(),
    );
    await _ds.update(folder);

    state = state.whenData(
      (current) => current.copyWith(
        folders: current.folders
            .map((f) => f.id == folder.id ? folder : f)
            .toList(),
      ),
    );
  }
}
