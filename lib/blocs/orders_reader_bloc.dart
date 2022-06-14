import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_admin/models/data_models/date.dart';
import 'package:grocery_admin/models/data_models/order.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:rxdart/rxdart.dart';

class OrdersReaderBloc {
  final Database database;

  OrdersReaderBloc({required this.database});

  // ignore: close_sinks
  StreamController<List<Order>> ordersController = BehaviorSubject();

  Stream<List<Order>> get ordersStream => ordersController.stream;

  bool _canLoadMore = true;

  List<DocumentSnapshot> _lastDocuments = [];

  List<Order> savedOrders = [];

  Future<void> refresh(int length, String status, [Date? date]) async {
    _canLoadMore = true;
    _lastDocuments = [];
    savedOrders = [];
    await loadOrders(status, length, date);
  }

  Future<void> loadOrders(String status, int length, [Date? date]) async {
    if (_canLoadMore) {
      _canLoadMore = false;

      List<Order> newProducts = (await _getOrders(status, length, date))
          .map((e) => Order.fromMap(
              e.data() as Map<String, dynamic>, e.id, e.reference.path))
          .toList();

      savedOrders.addAll(newProducts);

      ordersController.add(savedOrders.toSet().toList());

      if (newProducts.length < length) {
        _canLoadMore = false;
      } else {
        _canLoadMore = true;
      }
    }
  }

  void removeOrderLocally(Order order) {
    savedOrders.remove(order);
    ordersController.add(savedOrders);
  }

  Future<List<DocumentSnapshot>> _getOrders(
      String status, int length, Date? date) async {
    final collection =
        await (database.getFutureCollectionGroupWithRangeAndValue(
      'orders',
      startAfter: _lastDocuments.isEmpty ? null : _lastDocuments.last,
      length: length,
      orderBy: 'date',
      key: 'status',
      value: status,
      date: date,
    ));

    if (collection.docs.isNotEmpty) {
      _lastDocuments.add(collection.docs.last);
    }

    return collection.docs;
  }
}
