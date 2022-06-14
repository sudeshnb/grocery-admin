import 'package:grocery_admin/models/data_models/shipping_method.dart';
import 'package:grocery_admin/services/database.dart';

class ShippingBloc {
  final Database database;

  ShippingBloc({required this.database});

  //Get list of shipping methods
  Stream<List<ShippingMethod>> getShippingMethods() {
    return database.getDataFromCollection("shipping").map((snapshots) =>
        snapshots.docs
            .map((snapshot) => ShippingMethod.fromMap(
                snapshot.data() as Map<String, dynamic>,
                snapshot.reference.path))
            .toList());
  }

  //Delete shipping method
  Future<void> deleteShipping(String path) async {
    await database.removeData(path);
  }
}
