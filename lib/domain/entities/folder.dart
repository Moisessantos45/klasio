import 'package:klasio/domain/entities/pagination.dart';

class Folder {
  final int? id;
  final String name;
  final int indexIcon;
  final int indexColor;
  final int captureCount;
  final DateTime createdAt;

  const Folder({
    this.id,
    required this.name,
    required this.indexIcon,
    required this.indexColor,
    required this.createdAt,
    this.captureCount = 0,
  });

  Folder copyWith({
    int? id,
    String? name,
    int? indexIcon,
    int? indexColor,
    int? captureCount,
    DateTime? createdAt,
  }) => Folder(
    id: id ?? this.id,
    name: name ?? this.name,
    indexIcon: indexIcon ?? this.indexIcon,
    indexColor: indexColor ?? this.indexColor,
    captureCount: captureCount ?? this.captureCount,
    createdAt: createdAt ?? this.createdAt,
  );
}

class FolderList {
  final List<Folder> folders;
  final Pagination pagination;

  const FolderList({required this.folders, required this.pagination});

  FolderList copyWith({List<Folder>? folders, Pagination? pagination}) =>
      FolderList(
        folders: folders ?? this.folders,
        pagination: pagination ?? this.pagination,
      );
}

class FolderWithTotal {
  final List<Folder> folders;
  final int total;

  FolderWithTotal({required this.folders, required this.total});
}
