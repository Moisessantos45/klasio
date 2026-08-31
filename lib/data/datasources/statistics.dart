import 'package:klasio/core/database/app_database.dart';
import 'package:klasio/data/mappers/capture_mapper.dart';
import 'package:klasio/data/mappers/folder_mapper.dart';
import 'package:klasio/domain/entities/capture.dart';
import 'package:klasio/domain/entities/folder.dart';
import 'package:klasio/domain/entities/statistics.dart';
import 'package:sqflite/sqflite.dart';

class StatisticsDatasource {
  Future<Statistics> getStatistics() async {
    final db = await DatabaseHelper().database;

    final totalFolders =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) AS c FROM folders'),
        ) ??
        0;

    final totalCaptures =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) AS c FROM captures'),
        ) ??
        0;

    final foldersRes = await db.rawQuery('''
    SELECT
      f.id,
      f.name,
      f.index_color,
      f.index_icon,
      f.created_at,
      COALESCE(cnt.captures_count, 0) AS captures_count
    FROM folders f
    LEFT JOIN (
      SELECT folder_id, COUNT(*) AS captures_count
      FROM captures
      GROUP BY folder_id
    ) cnt ON cnt.folder_id = f.id
    ORDER BY f.created_at DESC
    LIMIT 4
  ''');

    final recentFolders = FolderWithTotal(
      folders: foldersRes.map((m) => FolderMapper.fromMap(m)).toList(),
      total: totalFolders,
    );

    final capturesRes = await db.rawQuery('''
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
    ORDER BY c.created_at DESC
    LIMIT 4
  ''');

    final lastCaptures = CaptureWithTotal(
      captures: capturesRes.map((m) => CaptureMapper.fromMap(m)).toList(),
      total: totalCaptures,
    );

    return Statistics(
      totalCaptures: totalCaptures,
      totalFolders: totalFolders,
      recentFolders: recentFolders,
      lastCaptures: lastCaptures,
    );
  }
}
