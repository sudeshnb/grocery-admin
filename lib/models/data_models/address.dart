class Address {
  final String name;
  final String address;
  final String? city;
  final String state;
  final String country;
  final String zipCode;
  final String phone;

  Address({
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.phone,
  });

  factory Address.fromMap(Map<String, dynamic> data) {
    return Address(
      name: data['name'],
      address: data['address'],
      city: data['city'],
      state: data['state'],
      country: data['country'],
      zipCode: data['zip_code'],
      phone: data['phone'],
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return (address) +
        (city != null ? ", $city" : "") +
        ", $state" +
        ", $zipCode" +
        ", $country";
  }
}
