import 'package:klasio/core/database/app_database.dart';
import 'package:klasio/data/mappers/capture_mapper.dart';
import 'package:klasio/domain/entities/capture.dart';
import 'package:sqflite/sqflite.dart';

class CaptureDatasource {
  Future<Capture> insert(Capture capture) async {
    final db = await DatabaseHelper().database;
    return db.transaction((txn) async {
      final id = await txn.insert('captures', CaptureMapper.toMap(capture));
      for (final tagId in capture.tagIds) {
        await txn.insert('capture_tags', {'capture_id': id, 'tag_id': tagId});
      }
      return capture.copyWith(id: id);
    });
  }

  Future<List<Capture>> getByFolderId(int folderId) async {
    final db = await DatabaseHelper().database;
    final maps = await db.rawQuery(
      '''
    SELECT
      c.id,
      c.folder_id,
      c.name,
      c.path,
      c.created_at,
      c.index_bg_color,
      c.index_text_color,
      (SELECT GROUP_CONCAT(ct.tag_id)
       FROM capture_tags ct
       WHERE ct.capture_id = c.id) AS tag_ids,
      (SELECT GROUP_CONCAT(t.id || '::' || t.name || '::' || t.created_at, '|||')
       FROM capture_tags ct
       INNER JOIN tags t ON t.id = ct.tag_id
       WHERE ct.capture_id = c.id) AS tags_data
    FROM captures c
    WHERE c.folder_id = ?
    ORDER BY c.created_at DESC
  ''',
      [folderId],
    );

    return maps.map((m) => CaptureMapper.fromMap(m)).toList();
  }

  Future<CaptureWithTotal> getAll({
    int folderId = 0,
    int tagId = 0,
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await DatabaseHelper().database;

    final conditions = <String>[];
    final whereArgs = <dynamic>[];

    if (folderId != 0) {
      conditions.add('c.folder_id = ?');
      whereArgs.add(folderId);
    }

    if (tagId != 0) {
      conditions.add(
        'c.id IN (SELECT capture_id FROM capture_tags WHERE tag_id = ?)',
      );
      whereArgs.add(tagId);
    }

    final where = conditions.isNotEmpty
        ? 'WHERE ${conditions.join(' AND ')}'
        : '';

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM captures c $where',
      whereArgs,
    );
    final total = Sqflite.firstIntValue(totalResult) ?? 0;

    final maps = await db.rawQuery(
      '''
    SELECT
      c.id,
      c.folder_id,
      c.name,
      c.path,
      c.created_at,
      c.index_bg_color,
      c.index_text_color,
      (SELECT GROUP_CONCAT(ct.tag_id)
       FROM capture_tags ct
       WHERE ct.capture_id = c.id) AS tag_ids,
      (SELECT GROUP_CONCAT(t.id || '::' || t.name || '::' || t.created_at, '|||')
       FROM capture_tags ct
       INNER JOIN tags t ON t.id = ct.tag_id
       WHERE ct.capture_id = c.id) AS tags_data
    FROM captures c
    $where
    ORDER BY c.created_at DESC
    LIMIT ? OFFSET ?
  ''',
      [...whereArgs, limit, offset],
    );

    final captures = maps.map((m) => CaptureMapper.fromMap(m)).toList();

    return CaptureWithTotal(captures: captures, total: total);
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper().database;
    return db.delete('captures', where: 'id = ?', whereArgs: [id]);
  }

  Future<Capture?> getById(int id) async {
    final db = await DatabaseHelper().database;
    final maps = await db.rawQuery(
      '''
    SELECT
      c.id,
      c.folder_id,
      c.name,
      c.path,
      c.created_at,
      c.index_bg_color,
      c.index_text_color,
      (SELECT GROUP_CONCAT(ct.tag_id)
       FROM capture_tags ct
       WHERE ct.capture_id = c.id) AS tag_ids,
      (SELECT GROUP_CONCAT(t.id || '::' || t.name || '::' || t.created_at, '|||')
       FROM capture_tags ct
       INNER JOIN tags t ON t.id = ct.tag_id
       WHERE ct.capture_id = c.id) AS tags_data
    FROM captures c
    WHERE c.id = ?
    LIMIT 1
  ''',
      [id],
    );
    if (maps.isEmpty) return null;
    return CaptureMapper.fromMap(maps.first);
  }

  Future<int> update(Capture capture) async {
    final db = await DatabaseHelper().database;
    return db.transaction((txn) async {
      final res = await txn.update(
        'captures',
        CaptureMapper.toMapForUpdate(capture),
        where: 'id = ?',
        whereArgs: [capture.id],
      );
      await txn.delete(
        'capture_tags',
        where: 'capture_id = ?',
        whereArgs: [capture.id],
      );
      for (final tagId in capture.tagIds) {
        await txn.insert('capture_tags', {
          'capture_id': capture.id,
          'tag_id': tagId,
        });
      }
      return res;
    });
  }

  Future<void> setTags(int captureId, List<int> tagIds) async {
    final db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      await txn.delete(
        'capture_tags',
        where: 'capture_id = ?',
        whereArgs: [captureId],
      );
      for (final tagId in tagIds) {
        await txn.insert('capture_tags', {
          'capture_id': captureId,
          'tag_id': tagId,
        });
      }
    });
  }
}
