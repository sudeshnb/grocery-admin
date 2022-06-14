import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_admin/models/data_models/date.dart';

abstract class Database {
  Stream<QuerySnapshot> getDataFromCollection(String path, [int length]);

  Future<QuerySnapshot> getFutureDataFromCollectionWithRange(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length});

  Future<QuerySnapshot> getFutureCollectionWithRangeAndSearch(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length,
      required String searchedData});

  Future<QuerySnapshot> getFutureCollectionGroupWithRangeAndValue(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length,
      required String key,
      required String value,
      Date? date});

  Future<QuerySnapshot> getFutureCollection(String col);

  Future<DocumentSnapshot> getFutureDataFromDocument(String path);

  Stream<QuerySnapshot> getFromCollectionGroup(String collectionName,
      int length, String valueName, String value, String orderBy, Date? date);

  Stream<QuerySnapshot> getSearchedDataFromCollection(
      String collection, String searchedData);

  Stream<DocumentSnapshot> getDataFromDocument(String path);

  Future<void> setData(Map<String, dynamic> data, String path);

  Future<void> removeData(String path);

  Future<void> removeCollection(String path);

  Future<void> updateData(Map<String, dynamic> data, String path);
}

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase implements Database {
  final _service = FirebaseFirestore.instance;

  Future<QuerySnapshot> getFutureCollectionWithRangeAndSearch(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length,
      required String searchedData}) async {
    if (startAfter != null) {
      return await _service
          .collection(path)
          .where('title', isGreaterThanOrEqualTo: searchedData)
          .where('title', isLessThan: searchedData + 'z')
          .orderBy(orderBy)
          .startAfterDocument(startAfter)
          .limit(length)
          .get();
    } else {
      return await _service
          .collection(path)
          .where('title', isGreaterThanOrEqualTo: searchedData)
          .where('title', isLessThan: searchedData + 'z')
          .orderBy(orderBy)
          .limit(length)
          .get();
    }
  }

  Future<QuerySnapshot> getFutureCollectionGroupWithRangeAndValue(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length,
      required String key,
      required String value,
      Date? date}) async {
    if (date != null) {
      if (startAfter != null) {
        return await _service
            .collectionGroup(path)
            .where(key, isEqualTo: value)
            .where('date', isGreaterThanOrEqualTo: date.firstDay)
            .where('date', isLessThanOrEqualTo: date.lastDay + 'z')
            .orderBy(orderBy)
            .startAfterDocument(startAfter)
            .limit(length)
            .get();
      } else {
        return await _service
            .collectionGroup(path)
            .where(key, isEqualTo: value)
            .where('date', isGreaterThanOrEqualTo: date.firstDay)
            .where('date', isLessThanOrEqualTo: date.lastDay + 'z')
            .orderBy(orderBy, descending: value == "Processing" ? false : true)
            .limit(length)
            .get();
      }
    } else {
      if (startAfter != null) {
        return await _service
            .collectionGroup(path)
            .where(key, isEqualTo: value)
            .orderBy(orderBy)
            .startAfterDocument(startAfter)
            .limit(length)
            .get();
      } else {
        return await _service
            .collectionGroup(path)
            .where(key, isEqualTo: value)
            .orderBy(orderBy, descending: value == "Processing" ? false : true)
            .limit(length)
            .get();
      }
    }
  }

  Future<QuerySnapshot> getFutureDataFromCollectionWithRange(String path,
      {required String orderBy,
      required DocumentSnapshot? startAfter,
      required int length}) async {
    if (startAfter != null) {
      return await _service
          .collection(path)
          .orderBy(orderBy)
          .startAfterDocument(startAfter)
          .limit(length)
          .get();
    } else {
      return await _service
          .collection(path)
          .orderBy(orderBy)
          .limit(length)
          .get();
    }
  }

  Future<DocumentSnapshot> getFutureDataFromDocument(String path) {
    return _service.doc(path).get();
  }

  Future<QuerySnapshot> getFutureCollection(String col) {
    return _service.collection(col).get();
  }

  Stream<QuerySnapshot> getFromCollectionGroup(String collectionName,
      int length, String valueName, String value, String orderBy, Date? date) {
    if (date == null) {
      return _service
          .collectionGroup(collectionName)
          .where(valueName, isEqualTo: value)
          .orderBy(orderBy, descending: value == "Processing" ? false : true)
          .limit(length)
          .snapshots();
    } else {
      return _service
          .collectionGroup(collectionName)
          .where('date', isGreaterThanOrEqualTo: date.firstDay)
          .where('date', isLessThanOrEqualTo: date.lastDay + 'z')
          .where(valueName, isEqualTo: value)
          .orderBy(orderBy, descending: value == "Processing" ? false : true)
          .limit(length)
          .snapshots();
    }
  }

  Stream<QuerySnapshot> getSearchedDataFromCollection(
      String collection, String searchedData) {
    final snapshots = _service
        .collection(collection)
        .where('title', isGreaterThanOrEqualTo: searchedData)
        .where('title', isLessThan: searchedData + 'z')
        .snapshots();

    return snapshots;
  }

  Stream<QuerySnapshot> getDataFromCollection(String path, [int? length]) {
    Stream<QuerySnapshot> snapshots;

    if (length == null) {
      snapshots = _service.collection(path).snapshots();
    } else {
      snapshots = _service.collection(path).limit(length).snapshots();
    }

    return snapshots;
  }

  Stream<DocumentSnapshot> getDataFromDocument(String path) {
    final snapshots = _service.doc(path).snapshots();

    return snapshots;
  }

  Future<void> setData(Map<String, dynamic> data, String path) async {
    final snapshots = _service.doc(path);
    await snapshots.set(data);
  }

  Future<void> updateData(Map<String, dynamic> data, String path) async {
    final snapshots = _service.doc(path);
    await snapshots.update(data);
  }

  Future<void> removeData(String path) async {
    final snapshots = _service.doc(path);
    await snapshots.delete();
  }

  Future<void> removeCollection(String path) async {
    await _service.collection(path).get().then((snapshot) async {
      await Future.forEach<QueryDocumentSnapshot>(snapshot.docs, (doc) async {
        await doc.reference.delete();
      });
    });
  }
}
