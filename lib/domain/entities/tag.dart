class Tag {
  final int id;
  final String name;
  final DateTime createdAt;

  const Tag({required this.id, required this.name, required this.createdAt});

  Tag copyWith({int? id, String? name, DateTime? createdAt}) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
}
