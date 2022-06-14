class ShippingMethod {
  final String title;
  final num price;
  final String? duration;

  final String? path;

  ShippingMethod({
    required this.title,
    required this.price,
    this.duration,
    this.path,
  });

  factory ShippingMethod.fromMap(Map<String, dynamic> data, String path) {
    return ShippingMethod(
        title: data['title'],
        price: data['price'],
        duration: data['duration'],
        path: path);
  }
}
