class DeliveryBoy {
  final String fullName;
  final String email;
  final String? image;

  DeliveryBoy({
    required this.fullName,
    required this.email,
    required this.image,
  });

  factory DeliveryBoy.fromMap(Map data, [String? email]) {
    return DeliveryBoy(
      fullName: data['full_name'],
      email: email ?? data['email'],
      image: data['image'],
    );
  }
}
