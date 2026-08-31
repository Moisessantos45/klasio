import 'package:klasio/core/database/app_database.dart';
import 'package:klasio/data/mappers/folder_mapper.dart';
import 'package:klasio/domain/entities/folder.dart';
import 'package:sqflite/sqflite.dart';

class FolderDatasource {
  Future<Folder> insert(Folder folder) async {
    final db = await DatabaseHelper().database;
    final id = await db.insert('folders', FolderMapper.toMap(folder));
    return folder.copyWith(id: id);
  }

  Future<FolderWithTotal> getAll({
    int? parentId,
    int limit = 10,
    int offset = 0,
    String query = '',
  }) async {
    final db = await DatabaseHelper().database;

    final List<String> conditions = [];
    final List<dynamic> whereArgs = [];

    if (parentId == null) {
      conditions.add('f.parent_id IS NULL');
    } else {
      conditions.add('f.parent_id = ?');
      whereArgs.add(parentId);
    }

    if (query.isNotEmpty) {
      conditions.add('f.name LIKE ?');
      whereArgs.add('%$query%');
    }

    final where = conditions.isNotEmpty ? 'WHERE ${conditions.join(" AND ")}' : '';

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM folders f $where',
      whereArgs,
    );
    final total = Sqflite.firstIntValue(totalResult) ?? 0;

    final maps = await db.rawQuery(
      '''
    SELECT
      f.id,
      f.parent_id,
      f.name,
      f.index_icon,
      f.index_color,
      f.created_at,
      COUNT(c.id) AS captures_count
    FROM folders f
    LEFT JOIN captures c ON c.folder_id = f.id
    $where
    GROUP BY f.id
    ORDER BY f.created_at DESC
    LIMIT ? OFFSET ?
  ''',
      [...whereArgs, limit, offset],
    );

    return FolderWithTotal(
      folders: maps.map((map) => FolderMapper.fromMap(map)).toList(),
      total: total,
    );
  }

  Future<List<Folder>> getSubfolders(int parentId) async {
    final db = await DatabaseHelper().database;
    final maps = await db.rawQuery(
      '''
    SELECT
      f.id,
      f.parent_id,
      f.name,
      f.index_icon,
      f.index_color,
      f.created_at,
      COUNT(c.id) AS captures_count
    FROM folders f
    LEFT JOIN captures c ON c.folder_id = f.id
    WHERE f.parent_id = ?
    GROUP BY f.id
    ORDER BY f.created_at DESC
  ''',
      [parentId],
    );

    return maps.map((map) => FolderMapper.fromMap(map)).toList();
  }

  Future<Folder?> getById(int id) async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('folders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return FolderMapper.fromMap(maps.first);
  }

  Future<int> update(Folder folder) async {
    final db = await DatabaseHelper().database;
    return db.update(
      'folders',
      FolderMapper.toMap(folder),
      where: 'id = ?',
      whereArgs: [folder.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper().database;
    return db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }
}
