import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_admin/models/data_models/product.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:rxdart/rxdart.dart';

class ProductsBloc {
  final Database database;

  ProductsBloc({required this.database});

  // ignore: close_sinks
  StreamController<List<Product>> productsController = BehaviorSubject();

  Stream<List<Product>> get productsStream =>
      productsController.stream;

  bool _canLoadMore = true;

  List<DocumentSnapshot> _lastDocuments = [];

  List<Product> savedProducts = [];

  Future<void> loadProducts(int length) async {
    if (_canLoadMore) {
      _canLoadMore = false;

      List<Product> newProducts = (await _getProducts(length))
          .map((e) => Product.fromMap(e.data() as Map<String, dynamic>, e.id))
          .toList();

      savedProducts.addAll(newProducts);

      productsController.add(savedProducts.toSet().toList());

      if (newProducts.length < length) {
        _canLoadMore = false;
      } else {
        _canLoadMore = true;
      }
    }
  }

  void refresh(int length) {
    _canLoadMore = true;
    _lastDocuments = [];
    savedProducts = [];
    loadProducts(length);
  }

  void addProductLocally(Product product){
    savedProducts.add(product);
    productsController.add(savedProducts);
  }

  void removeProductLocally(Product product){
    savedProducts.remove(product);
    productsController.add(savedProducts);
  }

  void editProductLocally(Product product){

    savedProducts.removeWhere((p)=> p.reference==product.reference);
    savedProducts.add(product);

    productsController.add(savedProducts);
  }


  Future<List<DocumentSnapshot>> _getProducts(int length) async {
    final collection = await (database.getFutureDataFromCollectionWithRange(
        'products',
        startAfter: _lastDocuments.isEmpty ? null : _lastDocuments.last,
        length: length,
        orderBy: 'date'));

    if (collection.docs.isNotEmpty) {
      _lastDocuments.add(collection.docs.last);
    }

    return collection.docs;
  }

  //Remove Product
  Future<void> removeProduct(String reference) async {
    await database.removeData('products/$reference');
  }
}
