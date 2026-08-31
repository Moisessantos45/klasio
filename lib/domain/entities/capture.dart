import 'package:klasio/domain/entities/pagination.dart';
import 'package:klasio/domain/entities/tag.dart';

class Capture {
  final int? id;
  final int? folderId;
  final String name;
  final String path;
  final DateTime createdAt;
  final List<int> tagIds;
  final int indexBgColor;
  final int indexTextColor;
  final List<Tag> tags;

  const Capture({
    this.id,
    this.folderId,
    required this.name,
    required this.path,
    required this.createdAt,
    this.tagIds = const [],
    this.indexBgColor = 0,
    this.indexTextColor = 0,
    this.tags = const [],
  });

  Capture copyWith({
    int? id,
    int? folderId,
    String? name,
    String? path,
    DateTime? createdAt,
    List<int>? tagIds,
    int? indexBgColor,
    int? indexTextColor,
    List<Tag>? tags,
  }) => Capture(
    id: id ?? this.id,
    folderId: folderId ?? this.folderId,
    name: name ?? this.name,
    path: path ?? this.path,
    createdAt: createdAt ?? this.createdAt,
    tagIds: tagIds ?? this.tagIds,
    indexBgColor: indexBgColor ?? this.indexBgColor,
    indexTextColor: indexTextColor ?? this.indexTextColor,
    tags: tags ?? this.tags,
  );
}

class CaptureList {
  final List<Capture> captures;
  final Pagination pagination;

  const CaptureList({required this.captures, required this.pagination});

  CaptureList copyWith({List<Capture>? captures, Pagination? pagination}) =>
      CaptureList(
        captures: captures ?? this.captures,
        pagination: pagination ?? this.pagination,
      );
}

class CaptureWithTotal {
  final List<Capture> captures;
  final int total;

  CaptureWithTotal({required this.captures, required this.total});
}
