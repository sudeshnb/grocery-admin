import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/services/database.dart';

class AddShippingModel with ChangeNotifier {
  final Database database;

  AddShippingModel({required this.database});

  bool validTitle = true;
  bool validPrice = true;
  bool validDuration = true;

  bool isLoading = false;

  //Add shipping method
  Future<void> submit(BuildContext context, String? path, String title,
      String duration, String price) async {
    if (verifyInputs(context, title, duration, price)) {
      isLoading = true;
      notifyListeners();

      if (path == null) {
        DateTime dateTime = DateTime.now();

        String id = dateTime.year.toString() +
            dateTime.month.toString() +
            dateTime.day.toString() +
            dateTime.hour.toString() +
            dateTime.minute.toString() +
            dateTime.second.toString() +
            dateTime.microsecond.toString();

        await database.setData(
            {'title': title, 'duration': duration, 'price': num.parse(price)},
            'shipping/$id');
      } else {
        await database.updateData(
            {'title': title, 'duration': duration, 'price': num.parse(price)},
            path);
      }

      Navigator.pop(context, true);

      isLoading = false;
      notifyListeners();
    }
  }

  //Verify inputs and show errors
  bool verifyInputs(
      BuildContext context, String title, String duration, String price) {
    bool result = true;

    if (title.replaceAll(" ", "").length == 0) {
      validTitle = false;
      result = false;
    } else {
      validTitle = true;
    }

    if (duration.length == 0) {
      validDuration = false;
      result = false;
    } else {
      validDuration = true;
    }

    if (price.length == 0) {
      validPrice = false;

      result = false;
    } else if (num.parse(price) < 0) {
      validPrice = false;
      result = false;
    } else {
      validPrice = true;
    }

    if (!result) {
      notifyListeners();
    }

    return result;
  }
}
