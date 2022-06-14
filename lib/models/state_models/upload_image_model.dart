import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:grocery_admin/services/auth.dart';

class UploadImageModel {
  final AuthBase auth;

  UploadImageModel({required this.auth});

  String get uid => auth.uid;

  String? get profileImage => auth.profileImage;

  Future<void> uploadImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      File image = File(result.files.single.path!);

      ///Resize Image to reduce upload size
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(image.path);
      File compressedImage = await FlutterNativeImage.compressImage(image.path,
          quality: 100,
          targetWidth: 400,
          targetHeight: (properties.height! * 400 / properties.width!).round());

      //profile_images
      FirebaseStorage storage = FirebaseStorage.instance;

      DateTime dateTime = DateTime.now();

      ///Upload image to firebase storage
      UploadTask task = storage
          .ref()
          .child(
              'profile_images/$uid/${dateTime.toString() + result.names.single!}')
          .putFile(compressedImage);

      late String url;

      await task.whenComplete(() async {
        url = await task.snapshot.ref.getDownloadURL();
      });

      ///Update profile image
      await auth.editImage(url);
    } else {
      // User canceled the picker
    }
  }
}
