class PaginationResponseModel<T> {
  final String? next;
  final String? previous;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final List<T> results;

  PaginationResponseModel({
    this.next,
    this.previous,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.results,
  });

  factory PaginationResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    try {
      final Map<String, dynamic> data =
          json['data'] is Map<String, dynamic> ? json['data'] : json;

      final dynamic rawListSource = data['records'] ??
          data['results'] ??
          data['data'] ??
          json['records'] ??
          json['results'] ??
          json['data'];

      final List<dynamic>? rawList = rawListSource is List
          ? rawListSource
          : rawListSource is Map<String, dynamic>
              ? rawListSource.values.toList()
              : null;

      final List<T> resultsList = (rawList != null)
          ? rawList.map<T>((item) {
              if (item is Map<String, dynamic>) {
                return fromJsonT(item);
              } else if (item is Map) {
                return fromJsonT(Map<String, dynamic>.from(item));
              } else {
                return fromJsonT({'id': 'unknown'});
              }
            }).toList()
          : <T>[];

      final int totalItems = data['totalRecords'] ??
          data['total_items'] ??
          data['count'] ??
          data['recordShown'] ??
          json['totalRecords'] ??
          json['total_items'] ??
          json['count'] ??
          resultsList.length;

      final int totalPages = data['totalPages'] ??
          data['total_pages'] ??
          data['pages'] ??
          json['totalPages'] ??
          json['total_pages'] ??
          json['pages'] ??
          1;

      final int currentPage = data['currentPage'] ??
          data['current_page'] ??
          data['page'] ??
          json['currentPage'] ??
          json['current_page'] ??
          json['page'] ??
          1;

      final int pageSize = data['perPage'] ??
          data['page_size'] ??
          data['limit'] ??
          json['perPage'] ??
          json['page_size'] ??
          json['limit'] ??
          10;

      final String? nextPage = (data['next']?.toString().isNotEmpty ?? false)
          ? data['next'].toString()
          : (json['next']?.toString().isNotEmpty ?? false)
              ? json['next'].toString()
              : null;
      final String? prevPage = (data['prev']?.toString().isNotEmpty ?? false)
          ? data['prev'].toString()
          : (json['prev']?.toString().isNotEmpty ?? false)
              ? json['prev'].toString()
              : null;

      return PaginationResponseModel(
        next: nextPage,
        previous: prevPage,
        totalItems: totalItems,
        totalPages: totalPages,
        currentPage: currentPage,
        pageSize: pageSize,
        results: resultsList,
      );
    } catch (e) {
      return PaginationResponseModel(
        next: null,
        previous: null,
        totalItems: 0,
        totalPages: 1,
        currentPage: 1,
        pageSize: 10,
        results: <T>[],
      );
    }
  }
}
