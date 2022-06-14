import 'dart:async';
import 'package:grocery_admin/models/data_models/delivery_boy.dart';
import 'package:grocery_admin/services/database.dart';

class DeliveryBoysBloc {
  late Database database;

  DeliveryBoysBloc({required Database database}) {
    this.database = database;
  }

  Stream<List<DeliveryBoy>> getDeliveryBoys() {
    return database.getDataFromCollection('delivery_boys').map((snapshots) =>
        snapshots.docs
            .map((snapshot) => DeliveryBoy.fromMap(
                snapshot.data() as Map<String, dynamic>, snapshot.id))
            .toList());
  }

  Future<void> removeDelivery(String email) async {
    await database.removeData('delivery_boys/$email');
  }
}
