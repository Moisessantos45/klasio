import 'package:klasio/domain/entities/capture.dart';
import 'package:klasio/domain/entities/tag.dart';

class CaptureMapper {
  static List<Tag> parseTagsData(dynamic raw) {
    if (raw == null) return const [];
    final str = raw.toString().trim();
    if (str.isEmpty) return const [];

    final tags = <Tag>[];
    for (final item in str.split('|||')) {
      final parts = item.split('::');
      if (parts.length >= 2) {
        final id = int.tryParse(parts[0]) ?? 0;
        final name = parts[1];
        final createdAt =
            parts.length > 2
                ? DateTime.tryParse(parts[2]) ?? DateTime.now()
                : DateTime.now();
        tags.add(Tag(id: id, name: name, createdAt: createdAt));
      }
    }
    return tags;
  }

  static List<int> parseTagIds(dynamic raw, [List<Tag> tags = const []]) {
    if (raw != null && raw.toString().trim().isNotEmpty) {
      return raw
          .toString()
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList();
    }
    if (tags.isNotEmpty) {
      return tags.map((t) => t.id).toList();
    }
    return const [];
  }

  static Capture fromMap(
    Map<String, dynamic> m, {
    List<int>? tagIds,
    List<Tag>? tags,
  }) {
    final parsedTags = tags ?? parseTagsData(m['tags_data'] ?? m['tagsData']);
    final parsedTagIds =
        tagIds ?? parseTagIds(m['tag_ids'] ?? m['tagIds'], parsedTags);

    return Capture(
      id: int.tryParse(m['id'].toString()) ?? 0,
      folderId:
          int.tryParse((m['folder_id'] ?? m['folderId']).toString()) ?? 0,
      name: m['name']?.toString() ?? '',
      path: m['path']?.toString() ?? '',
      createdAt: DateTime.parse(m['created_at'].toString()),
      tagIds: parsedTagIds,
      tags: parsedTags,
      indexBgColor:
          int.tryParse(
            (m['index_bg_color'] ?? m['indexBgColor']).toString(),
          ) ??
          0,
      indexTextColor:
          int.tryParse(
            (m['index_text_color'] ?? m['indexTextColor']).toString(),
          ) ??
          0,
    );
  }

  static Map<String, dynamic> toMap(Capture e) => {
    if (e.id != null) 'id': e.id,
    'folder_id': e.folderId,
    'name': e.name,
    'path': e.path,
    "index_bg_color": e.indexBgColor,
    "index_text_color": e.indexTextColor,
    'created_at': e.createdAt.toIso8601String(),
  };

  static Map<String, dynamic> toMapForUpdate(Capture e) => {
    'folder_id': e.folderId,
    'name': e.name,
    "index_bg_color": e.indexBgColor,
    "index_text_color": e.indexTextColor,
  };
}
