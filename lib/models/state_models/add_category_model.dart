import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/models/data_models/category.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/widgets/dialogs/error_dialog.dart';

class AddCategoryModel extends ChangeNotifier {
  final Database database;

  String image = 'images/upload_image.png';

  bool networkImage = false;

  bool validTitle = true;
  bool validImage = true;

  bool isLoading = false;

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

  Future<void> submit(
      BuildContext context, String title, Category? category) async {
    if (verifyInputs(title)) {
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
                  'categories/${image.split('/').last.replaceAll(".png", "") + id}')
              .putFile(imageFile);

          late String url;

          await task.whenComplete(() async {
            url = await task.snapshot.ref.getDownloadURL();
          });

          image = url;
        }

        if (category != null) {
          await database.removeData('categories/${category.title}');
        }

        await database.setData({"image": image}, 'categories/$title');

        isLoading = false;
        notifyListeners();

        Navigator.pop(context, true);
      } catch (e) {
        if (e is FirebaseException) {
          FirebaseException exception = e;

          showDialog(
              context: context,
              builder: (context) =>
                  ErrorDialog(message: exception.message!));
        }
        isLoading = false;
        notifyListeners();
      }
    }
  }

  bool verifyInputs(String title) {
    if (title.replaceAll(" ", "").isEmpty) {
      validTitle = false;
    } else {
      validTitle = true;
    }

    if (image == 'images/upload_image.png') {
      validImage = false;
    } else {
      validImage = true;
    }

    if (!validTitle || !validImage) {
      notifyListeners();
    }

    return validTitle && validImage;
  }

  AddCategoryModel({required this.database});
}
