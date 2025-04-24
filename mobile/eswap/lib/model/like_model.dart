class Like {
  final int postId;
  final bool liked;
  final int likesCount;

  Like({required this.postId, required this.liked, required this.likesCount});

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
        postId: json['postId'],
        liked: json['liked'],
        likesCount: json['likesCount']);
  }
}
