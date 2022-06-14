import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:grocery_admin/helpers/validators.dart';
import 'package:grocery_admin/models/data_models/delivery_boy.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/widgets/dialogs/error_dialog.dart';

class AddDeliveryBoyModel with ChangeNotifier {
  final Database database;

  bool isLoading = false;

  bool validFullName = true;
  bool validEmail = true;
  bool validPassword = true;

  bool networkImage = false;
  String? image;

  AddDeliveryBoyModel({required this.database});

  void changeImage() async {
    FilePickerResult? picker =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (picker != null) {
      image = picker.paths.single;
      networkImage = false;
      notifyListeners();
    }
  }

  Future<String> _uploadImage(String email) async {
    DateTime dateTime = DateTime.now();
    String id = dateTime.year.toString() +
        dateTime.month.toString() +
        dateTime.day.toString() +
        dateTime.hour.toString() +
        dateTime.minute.toString() +
        dateTime.microsecond.toString();

    ///Resize Image to reduce upload size
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(image!);
    File compressedImage = await FlutterNativeImage.compressImage(image!,
        quality: 100,
        targetWidth: 400,
        targetHeight: (properties.height! * 400 / properties.width!).round());

    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    UploadTask task = firebaseStorage
        .ref()
        .child(
            'profile_images/delivery_boys/$email/${id + image!.split('/').last}')
        .putFile(compressedImage);

    late String url;

    await task.whenComplete(() async {
      url = await task.snapshot.ref.getDownloadURL();
    });

    return url;
  }

  Future<void> submit(BuildContext context, String fullName, String email,
      {DeliveryBoy? deliveryBoy}) async {
    if (_verifyInputs(fullName, email)) {
      try {
        isLoading = true;
        notifyListeners();

        if (deliveryBoy != null) {
          if (deliveryBoy.image != image) {
            image = await _uploadImage(email);
          }

          await database.updateData({
            'full_name': fullName,
            'image': image,
          }, 'delivery_boys/$email');
        } else {
          List<String> deliveryBoysEmails =
              (await database.getFutureCollection('delivery_boys'))
                  .docs
                  .map((snapshot) => snapshot.id)
                  .toList();

          if (deliveryBoysEmails.contains(email)) {
            showDialog(
                context: context,
                builder: (context) => ErrorDialog(
                    message: 'This user is already exist'));
          } else {
            if (image != null) {
              image = await _uploadImage(email);
              networkImage = true;
            }

            await database.setData({
              'full_name': fullName,
              'image': image,
            }, 'delivery_boys/${email.toLowerCase()}');
          }
        }

        isLoading = false;
        notifyListeners();

        Navigator.pop(context);
      } catch (e) {
        print(e);

        isLoading = false;
        notifyListeners();
      }
    }
  }

  bool _verifyInputs(String fullName, String email) {
    bool result = true;

    if (Validators.name(fullName)) {
      validFullName = true;
    } else {
      validFullName = false;
      result = false;
    }

    if (Validators.email(email)) {
      validEmail = true;
    } else {
      validEmail = false;
      result = false;
    }

    if (!result) {
      notifyListeners();
    }

    return result;
  }
}
