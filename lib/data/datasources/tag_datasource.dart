import 'package:klasio/core/database/app_database.dart';
import 'package:klasio/data/mappers/tag_mapper.dart';
import 'package:klasio/domain/entities/tag.dart';

class TagDatasource {
  Future<Tag> insert(Tag tag) async {
    final db = await DatabaseHelper().database;
    final id = await db.insert('tags', TagMapper.toMap(tag));
    return tag.copyWith(id: id);
  }

  Future<List<Tag>> getAll() async {
    final db = await DatabaseHelper().database;
    final maps = await db.query('tags', orderBy: 'name ASC');
    return maps.map(TagMapper.fromMap).toList();
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper().database;
    return db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Tag>> getByCaptureId(int captureId) async {
    final db = await DatabaseHelper().database;
    final maps = await db.rawQuery(
      '''
      SELECT t.* FROM tags t
      INNER JOIN capture_tags ct ON ct.tag_id = t.id
      WHERE ct.capture_id = ?
    ''',
      [captureId],
    );
    return maps.map(TagMapper.fromMap).toList();
  }
}
