class Pagination {
  final int currentPage;
  final int totalPages;
  final int total;
  int pageSize;
  String query;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.total,
    this.pageSize = 10,
    this.query = '',
  });

  Pagination copyWith({
    int? currentPage,
    int? pageSize,
    int? totalPages,
    int? total,
    String? query,
  }) {
    return Pagination(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      query: query ?? this.query,
    );
  }
}
