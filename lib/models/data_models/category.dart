class Category {
  final String title;
  final String image;

  Category({required this.title, required this.image});

  factory Category.fromMap(Map data, String id) {
    return Category(title: id, image: data['image']);
  }
}
