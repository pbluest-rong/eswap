class PageResponse<T> {
  List<T> content;
  int number;
  int size;
  int totalElements;
  int totalPages;
  bool first;
  bool last;

  PageResponse({
    required this.content,
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory PageResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    return PageResponse<T>(
      content: (json['content'] as List).map((item) => fromJson(item)).toList(),
      number: json['number'],
      size: json['size'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      first: json['first'],
      last: json['last'],
    );
  }
}