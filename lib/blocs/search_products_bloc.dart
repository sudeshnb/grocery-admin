import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/models/data_models/product.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:rxdart/rxdart.dart';

class SearchProductsBloc {
  final Database database;

  SearchProductsBloc({required this.database});

  bool? _changesAffected;


  // ignore: close_sinks
  StreamController<List<Product>> productsController = BehaviorSubject();

  Stream<List<Product>> get productsStream => productsController.stream;

  bool _canLoadMore = true;

  void clearHistory() {
    _lastDocuments = [];
    savedProducts = [];
    _canLoadMore = true;
  }

  List<DocumentSnapshot> _lastDocuments = [];

  List<Product> savedProducts = [];

  Future<void> loadProducts(String text, int length) async {
    if (_canLoadMore) {
      _canLoadMore = false;

      List<Product> newProducts = (await getSearchedProducts(text, length))
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

  Future<List<DocumentSnapshot>> getSearchedProducts(
      String text, int length) async {
    final collection = await (database.getFutureCollectionWithRangeAndSearch(
        'products',
        startAfter: _lastDocuments.isEmpty ? null : _lastDocuments.last,
        length: length,
        orderBy: 'title',
        searchedData: text));

    if (collection.docs.isNotEmpty) {
      _lastDocuments.add(collection.docs.last);
    }

    return collection.docs;
  }

  void refresh(String text, int length) {
    _canLoadMore = true;
    _lastDocuments = [];
    savedProducts = [];
    loadProducts(text, length);
  }



  Future<bool> onWillPop(BuildContext context)async{
    if(_changesAffected!=null){
      Navigator.pop(context,true);
    }else{
      Navigator.pop(context);

    }
    return false;
  }

  void addProductLocally(Product product){
    savedProducts.add(product);
    productsController.add(savedProducts);
    _changesAffected=true;
  }

  void removeProductLocally(Product product){
    savedProducts.remove(product);
    productsController.add(savedProducts);
    _changesAffected=true;

  }

  void editProductLocally(Product product){
    savedProducts.removeWhere((p)=> p.reference==product.reference);
    savedProducts.add(product);

    productsController.add(savedProducts);
    _changesAffected=true;

  }


  ///Remove Product
  Future<void> removeProduct(String reference) async {
    await database.removeData('products/$reference');
  }
}
