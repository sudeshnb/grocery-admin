import 'package:flutter/cupertino.dart';
import 'package:grocery_admin/services/database.dart';

class AddCouponModel with ChangeNotifier {
  final Database database;

  AddCouponModel({required this.database});

  bool validCode = true;
  bool validValue = true;
  bool isLoading = false;

  bool isPercentage = true;

  int value = 50;

  void updateValue(int value) {
    this.value = value;
    notifyListeners();
  }

  void changeTypeStatus(bool value) {
    if (isPercentage != value) {
      isPercentage = !isPercentage;
      notifyListeners();
    }
  }

  void updateWidget() {
    notifyListeners();
  }

  //Add coupon
  Future<void> submit(BuildContext context,
      {required String code,
      required String type,
      required int value,
      required DateTime expiryDate,
      String? path}) async {
    if (verifyInputs(context, code)) {
      isLoading = true;
      notifyListeners();

      if (path == null) {
        await database.setData({
          'type': type,
          'value': value,
          'expiry_date': expiryDate.toString().substring(0, 10)
        }, 'coupons/$code');
      } else {
        if (path != "coupons/" + code) {
          await database.removeData(path);

          await database.setData({
            'type': type,
            'value': value,
            'expiry_date': expiryDate.toString().substring(0, 10)
          }, 'coupons/$code');
        } else {
          await database.updateData({
            'type': type,
            'value': value,
            'expiry_date': expiryDate.toString().substring(0, 10)
          }, 'coupons/$code');
        }
      }

      Navigator.pop(context, true);

      isLoading = false;
      notifyListeners();
    }
  }

  //Verify inputs and show errors
  bool verifyInputs(BuildContext context, String code) {
    bool result = true;

    if (code.replaceAll(" ", "").length == 0) {
      validCode = false;
      result = false;
    } else {
      validCode = true;
    }

    if (!result) {
      notifyListeners();
    }

    return result;
  }
}
