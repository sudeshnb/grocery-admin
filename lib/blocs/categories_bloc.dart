import 'dart:async';
import 'package:grocery_admin/models/data_models/category.dart';
import 'package:grocery_admin/services/database.dart';

class CategoriesBloc {
  final Database database;

  CategoriesBloc({required this.database});

  //Get list of categories
  Stream<List<Category>> getCategories() {
    return database
        .getDataFromCollection('categories')
        .map((snapshots) => snapshots.docs.map((snapshot) {
              return Category.fromMap(
                  snapshot.data() as Map<String, dynamic>, snapshot.id);
            }).toList());
  }

  //Remove Product
  Future<void> removeCategory(String category) async {
    await database.removeData('categories/$category');
  }
}
