import 'package:klasio/domain/entities/folder.dart';

class FolderMapper {
  static Folder fromMap(Map<String, dynamic> m) => Folder(
    id: int.tryParse(m['id'].toString()) ?? 0,
    parentId: m['parent_id'] != null ? int.tryParse(m['parent_id'].toString()) : null,
    name: m['name'] ?? '',
    indexIcon: int.tryParse(m['index_icon'].toString()) ?? 0,
    indexColor: int.tryParse(m['index_color'].toString()) ?? 0,
    createdAt: DateTime.parse(m['created_at'].toString()),
    captureCount: int.tryParse(m['captures_count'].toString()) ?? 0,
  );

  static Map<String, dynamic> toMap(Folder e) => {
    if (e.id != null) 'id': e.id,
    'parent_id': e.parentId,
    'name': e.name,
    'index_icon': e.indexIcon,
    'index_color': e.indexColor,
    'created_at': e.createdAt.toIso8601String(),
  };
}
