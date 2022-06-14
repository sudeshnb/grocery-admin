import 'package:grocery_admin/models/data_models/coupon.dart';
import 'package:grocery_admin/services/database.dart';

class CouponsBloc {
  final Database database;

  CouponsBloc({required this.database});

  ///Get list of coupons
  Stream<List<Coupon>> getCoupons() {
    return database.getDataFromCollection('coupons').map((snapshots) =>
        snapshots.docs
            .map((snapshot) => Coupon.fromMap(
                snapshot.data() as Map<String, dynamic>, snapshot.id))
            .toList());
  }

  ///Delete coupon
  Future<void> deleteCoupon(Coupon coupon) async {
    await database.removeData('coupons/' + coupon.code);
  }
}
