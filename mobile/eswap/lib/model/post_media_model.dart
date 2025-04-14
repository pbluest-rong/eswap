class PostMedia {
  final int id;
  final String originalUrl;
  final String contentType;

  PostMedia(
      {required this.id, required this.originalUrl, required this.contentType});

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
        id: json['id'],
        originalUrl: json['originalUrl'],
        contentType: json['contentType']);
  }
}
