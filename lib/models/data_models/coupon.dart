class Coupon {
  final String code;
  final String type;
  final int value;
  final DateTime expiryDate;
  final String? path;

  Coupon(
      {required this.code,
      required this.type,
      required this.value,
      required this.expiryDate,
      this.path});

  factory Coupon.fromMap(Map<String, dynamic> data, [String? id]) {
    return Coupon(
        code: (id == null) ? data['code'] : id,
        type: data['type'],
        value: int.parse(data['value'].toString()),
        expiryDate: DateTime.parse(data['expiry_date']),
        path: 'coupons/' + ((id == null) ? data['code'] : id));
  }
}
