import 'package:klasio/domain/entities/tag.dart';

class TagMapper {
  static Tag fromMap(Map<String, dynamic> m) => Tag(
    id: int.tryParse(m['id'].toString()) ?? 0,
    name: m['name'] ?? '',
    createdAt: DateTime.parse(m['created_at'].toString()),
  );

  static Map<String, dynamic> toMap(Tag e) => {
    if (e.id != 0) 'id': e.id,
    'name': e.name,
    'created_at': e.createdAt.toIso8601String(),
  };
}
