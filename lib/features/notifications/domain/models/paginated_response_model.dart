// class PaginationResponseModel<T> {
//   final String? next;
//   final String? previous;
//   final int totalItems;
//   final int totalPages;
//   final int currentPage;
//   final int pageSize;
//   final List<T> results;

//   PaginationResponseModel({
//     this.next,
//     this.previous,
//     required this.totalItems,
//     required this.totalPages,
//     required this.currentPage,
//     required this.pageSize,
//     required this.results,
//   });

//   factory PaginationResponseModel.fromJson(
//     Map<String, dynamic> json,
//     T Function(Map<String, dynamic>) fromJsonT,
//   ) {
//     try {
//       // Handle case when 'links' might be null or not present
//       Map<String, dynamic>? links;
//       if (json.containsKey('links')) {
//         links = json['links'] as Map<String, dynamic>?;
//       }

//       final List<T> resultsList;
//       if (json.containsKey('results') && json['results'] != null) {
//         resultsList = (json['results'] as List).map((item) {
//           if (item is Map<String, dynamic>) {
//             return fromJsonT(item);
//           } else {
//             // Handle non-Map items by converting to a minimal valid map
//             return fromJsonT({'id': 'unknown'});
//           }
//         }).toList();
//       } else if (json.containsKey('data') &&
//           json['data'] != null &&
//           json['data'] is List) {
//         resultsList = (json['data'] as List).map((item) {
//           if (item is Map<String, dynamic>) {
//             return fromJsonT(item);
//           } else {
//             return fromJsonT({'id': 'unknown'});
//           }
//         }).toList();
//       } else {
//         resultsList = <T>[];
//       }

//       return PaginationResponseModel(
//         next: links != null ? links['next'] as String? : null,
//         previous: links != null ? links['previous'] as String? : null,
//         totalItems: json['total_items'] as int? ?? resultsList.length,
//         totalPages: json['total_pages'] as int? ?? 1,
//         currentPage: json['current_page'] as int? ?? 1,
//         pageSize: json['page_size'] as int? ?? 10,
//         results: resultsList,
//       );
//     } catch (e) {
//       print('Error parsing pagination response: $e');
//       // Return an empty model on error
//       return PaginationResponseModel(
//         next: null,
//         previous: null,
//         totalItems: 0,
//         totalPages: 1,
//         currentPage: 1,
//         pageSize: 10,
//         results: <T>[],
//       );
//     }
//   }
// }
