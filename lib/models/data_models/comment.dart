class Comment {
  final String image;
  final String comment;

  Comment({required this.image, required this.comment});

  factory Comment.fromMap(Map data) {
    return Comment(image: data['image'], comment: data['comment']);
  }
}
