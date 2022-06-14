import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/models/data_models/category.dart';
import 'package:grocery_admin/models/data_models/product.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/widgets/dialogs/error_dialog.dart';

class AddProductModel with ChangeNotifier {
  final Database database;

  bool pricePerKgEnabled = false;
  bool networkImage = false;

  void updatePricePerKgState() {
    pricePerKgEnabled = !pricePerKgEnabled;
    notifyListeners();
  }

  void updateWidget() {
    notifyListeners();
  }

  String image = 'images/upload_image.png';
  String? category;

  bool validTitle = true;
  bool validCategory = true;
  bool validPricePerPiece = true;
  bool validPricePerKg = true;
  bool validDescription = true;
  bool validOrigin = true;
  bool validStorage = true;
  bool validImage = true;

  bool isLoading = false;

  //Add product
  Future<void> submit(
      BuildContext context,
      String title,
      String pricePerPiece,
      String description,
      String origin,
      String storage,
      String? path,
      String pricePerKg) async {
    if (validateInputs(context, title, pricePerPiece, description, origin,
        storage, pricePerKg)) {
      isLoading = true;
      notifyListeners();

      try {
        DateTime dateTime = DateTime.now();

        if (!networkImage) {
          FirebaseStorage firebaseStorage = FirebaseStorage.instance;
          String id = dateTime.year.toString() +
              dateTime.month.toString() +
              dateTime.day.toString() +
              dateTime.hour.toString() +
              dateTime.minute.toString() +
              dateTime.microsecond.toString();

          File imageFile = File(image);
          UploadTask task = firebaseStorage
              .ref()
              .child(
                  'products/${image.split('/').last.replaceAll(".png", "") + id}')
              .putFile(imageFile);

          late String url;

          await task.whenComplete(() async {
            url = await task.snapshot.ref.getDownloadURL();
          });

          image = url;
        }

        String date = dateTime.year.toString() +
            "-" +
            dateTime.month.toString() +
            "-" +
            dateTime.day.toString();

        final id=dateTime.month.toString() +
            dateTime.day.toString() +
            dateTime.second.toString() +
            dateTime.microsecond.toString();
        print(id);
        if (path == null) {
          path = "products/" +
              id;
        }

        Map<String, dynamic> data = {
          "date": date,
          "title": title,
          "image": image,
          "category": category,
          "price_per_piece": num.parse(pricePerPiece),
          "description": description,
          "origin": origin,
          "storage": storage,
        };

        if (pricePerKgEnabled) {
          data["price_per_kg"] = num.parse(pricePerKg);
        }

        await database.setData(data, path);

        isLoading = false;
        notifyListeners();

        Navigator.pop(context, Product.fromMap(data,path.split('/')[1]));
        print(id);

      } catch (e) {
        Navigator.pop(context);
        if (e is FirebaseException) {
          FirebaseException exception = e;

          showDialog(
              context: context,
              builder: (context) =>
                  ErrorDialog( message: exception.message!));
        }
        isLoading = false;
        notifyListeners();
      }
    }
  }

  //Verify inputs and show errors
  bool validateInputs(BuildContext context, String title, String pricePerPiece,
      String description, String origin, String storage, String pricePerKg) {
    bool result = true;

    if (image == 'images/upload_image.png') {
      validImage = false;
      result = false;
    } else {
      validImage = true;
    }

    if (title.replaceAll(" ", '').isEmpty) {
      validTitle = false;
      result = false;
    } else {
      validTitle = true;
    }
    if (category == null) {
      validCategory = false;
      result = false;
    } else {
      validCategory = true;
    }

    if (pricePerPiece.replaceAll(" ", '').isEmpty) {
      validPricePerPiece = false;
      result = false;
    } else if (num.parse(pricePerPiece) <= 0) {
      validPricePerPiece = false;
      result = false;
    } else {
      validPricePerPiece = true;
    }

    if (pricePerKgEnabled) {
      if (pricePerKg.replaceAll(" ", '').isEmpty) {
        validPricePerKg = false;
        result = false;
      } else if (num.parse(pricePerPiece) <= 0) {
        validPricePerKg = false;
        result = false;
      }
    } else {
      validPricePerKg = true;
    }

    if (description.replaceAll(" ", '').isEmpty) {
      validDescription = false;
      result = false;
    } else {
      validDescription = true;
    }

    if (origin.replaceAll(" ", '').isEmpty) {
      validOrigin = false;
      result = false;
    } else {
      validOrigin = true;
    }

    if (storage.replaceAll(" ", '').isEmpty) {
      validStorage = false;
      result = false;
    } else {
      validStorage = true;
    }
    if (!result) {
      notifyListeners();
    }

    return result;
  }

  //Upload image to firebase storage
  Future<void> chooseImage(BuildContext context) async {
    late FilePickerResult? result;
    try {
      result = await FilePicker.platform
          .pickFiles(type: FileType.image, allowedExtensions: ["png"]);
    } catch (e) {
      result = await FilePicker.platform.pickFiles(type: FileType.image);
    }

    if (result != null) {
      if (result.files.single.path!.substring(
              result.files.single.path!.length - 4,
              result.files.single.path!.length) ==
          ".png") {
        image = result.files.single.path!;
        networkImage = false;
        notifyListeners();
      } else {
        showDialog(
            context: context,
            builder: (context) {
             return const ErrorDialog(
                  message: "Please select a png image");
            });
      }
    } else {
      // User canceled the picker
    }
  }

  void changeCategory(String? value) {
    if (value != null && (value != "Add category")) {
      category = value;
      notifyListeners();
    }
  }

  void initCategory() {
    category = null;
    notifyListeners();
  }

  Stream<List<Category>> getCategories() {
    return database
        .getDataFromCollection('categories')
        .map((snapshots) => snapshots.docs.map((snapshot) {
              return Category.fromMap(
                  snapshot.data() as Map<String, dynamic>, snapshot.id);
            }).toList());
  }

  Future<void> deleteCategory(String category) async {
    await database.removeData('categories/$category');
  }

  AddProductModel({required this.database});
}

/*


 */
