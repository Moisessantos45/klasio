import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klasio/data/datasources/capture_datasource.dart';
import 'package:klasio/domain/entities/capture.dart';
import 'package:klasio/domain/entities/pagination.dart';

final captureDatasourceProvider = Provider<CaptureDatasource>(
  (ref) => CaptureDatasource(),
);

final captureNotifierProvider =
    AsyncNotifierProvider<CaptureNotifier, CaptureList>(CaptureNotifier.new);

class CaptureNotifier extends AsyncNotifier<CaptureList> {
  late final CaptureDatasource _ds;
  int _currentFolderId = 0;
  int _currentTagId = 0;

  @override
  Future<CaptureList> build() async {
    _ds = ref.read(captureDatasourceProvider);
    final result = await _ds.getAll(
      folderId: _currentFolderId,
      tagId: _currentTagId,
    );
    return CaptureList(
      captures: result.captures,
      pagination: Pagination(
        currentPage: 1,
        pageSize: 10,
        totalPages: result.total == 0 ? 1 : (result.total / 10).ceil(),
        total: result.total,
      ),
    );
  }

  Future<void> refresh() async {
    await getAll(folderId: _currentFolderId, tagId: _currentTagId);
  }

  Future<void> getAll({
    int folderId = 0,
    int tagId = 0,
    int page = 1,
    int pageSize = 10,
  }) async {
    _currentFolderId = folderId;
    _currentTagId = tagId;

    if (page <= 0) page = 1;
    if (pageSize <= 0) pageSize = 10;

    final offset = (page - 1) * pageSize;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _ds.getAll(
        folderId: folderId,
        tagId: tagId,
        limit: pageSize,
        offset: offset,
      );

      final totalPages = result.total == 0
          ? 1
          : (result.total / pageSize).ceil();

      return CaptureList(
        captures: result.captures,
        pagination: Pagination(
          currentPage: page,
          pageSize: pageSize,
          totalPages: totalPages,
          total: result.total,
        ),
      );
    });
  }

  Future<void> addCapture({
    required int folderId,
    required String name,
    required String path,
    List<int> tagIds = const [],
    required int indexBgColor,
    required int indexTextColor,
  }) async {
    final capture = Capture(
      folderId: folderId,
      name: name,
      path: path,
      createdAt: DateTime.now(),
      tagIds: tagIds,
      indexBgColor: indexBgColor,
      indexTextColor: indexTextColor,
    );

    final inserted = await _ds.insert(capture);
    state = state.whenData(
      (current) => current.copyWith(
        captures: [inserted, ...current.captures],
        pagination: current.pagination.copyWith(
          total: current.pagination.total + 1,
        ),
      ),
    );
  }

  Future<void> removeCapture(int id, {int? folderId}) async {
    await _ds.delete(id);
    state = state.whenData(
      (current) => current.copyWith(
        captures: current.captures.where((c) => c.id != id).toList(),
        pagination: current.pagination.copyWith(
          total: current.pagination.total - 1,
        ),
      ),
    );
  }

  Future<Capture?> getById(int id) async {
    return await _ds.getById(id);
  }

  Future<void> updateCapture({
    required int id,
    required int folderId,
    required String name,
    required String path,
    List<int> tagIds = const [],
    required int indexBgColor,
    required int indexTextColor,
  }) async {
    final existing = await _ds.getById(id);
    final createdAt = existing?.createdAt ?? DateTime.now();

    final capture = Capture(
      id: id,
      folderId: folderId,
      name: name,
      path: path,
      createdAt: createdAt,
      tagIds: tagIds,
      indexBgColor: indexBgColor,
      indexTextColor: indexTextColor,
    );

    await _ds.update(capture);
    state = state.whenData(
      (current) => current.copyWith(
        captures: current.captures.map((c) {
          if (c.id == id) {
            return capture;
          }
          return c;
        }).toList(),
      ),
    );
  }

  Future<void> updateTags(
    int captureId,
    List<int> tagIds, {
    int? folderId,
  }) async {
    await _ds.setTags(captureId, tagIds);
    state = state.whenData(
      (current) => current.copyWith(
        captures: current.captures.map((c) {
          if (c.id == captureId) {
            return c.copyWith(tagIds: tagIds);
          }
          return c;
        }).toList(),
      ),
    );
  }
}
