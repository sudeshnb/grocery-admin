class Product {
  final String title;
  final String image;
  final String storage;
  final String origin;
  final String reference;
  final String description;
  final num pricePerPiece;
  final num? pricePerKg;
  final String category;

  factory Product.fromMap(Map<String, dynamic> data, [String? reference]) {
    return Product(
        title: data['title'],
        image: data['image'],
        storage: data['storage'],
        origin: data['origin'],
        reference: (reference == null) ? data['reference'] : reference,
        pricePerPiece: data['price_per_piece'],
        pricePerKg:
            (data.containsKey('price_per_kg')) ? data['price_per_kg'] : null,
        category: data['category'],
        description: data['description']);
  }

  Product(
      {required this.title,
      required this.image,
      required this.storage,
      required this.origin,
      required this.reference,
      required this.pricePerPiece,
      required this.pricePerKg,
      required this.category,
      required this.description});
}
