import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/helpers/validators.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/widgets/dialogs/error_dialog.dart';

class UpdateInfoModel with ChangeNotifier {
  final AuthBase auth;

  bool validName = true;
  bool validEmail = true;

  bool isLoading = false;

  String? get fullName => auth.displayName;

  String? get email => auth.email;

  Future<void> submit(BuildContext context, String name, String email) async {
    if (verifyInputs(context, email, name)) {
      try {
        isLoading = true;
        notifyListeners();
        await auth.updateNameAndEmail(email, name);

        Navigator.pop(context, true);
      } catch (e) {
        FirebaseAuthException exception = e as FirebaseAuthException;

        showDialog(
            context: context,
            builder: (context) =>
                ErrorDialog(message: exception.message!));
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  bool verifyInputs(BuildContext context, String email, String name) {
    bool result = true;

    if (!Validators.name(name)) {
      validName = false;
      result = false;
    } else {
      validName = true;
    }

    if (!Validators.email(email)) {
      validEmail = false;
      result = false;
    } else {
      validEmail = true;
    }

    if (!result) {
      notifyListeners();
    }

    return result;
  }

  UpdateInfoModel({required this.auth});
}
