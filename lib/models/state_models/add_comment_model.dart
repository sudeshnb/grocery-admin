import 'package:flutter/cupertino.dart';
import 'package:grocery_admin/services/database.dart';

class AddCommentModel with ChangeNotifier {
  final Database database;

  bool validComment = true;

  bool isLoading = false;

  Future<void> submit(BuildContext context, String comment, String path) async {
    if (verifyInputs(comment)) {
      isLoading = true;
      notifyListeners();

      await database.updateData({
        'admin_comment': comment,
      }, path);

      isLoading = false;
      notifyListeners();

      Navigator.pop(context, true);
    }
  }

  bool verifyInputs(String comment) {
    if (comment.replaceAll(" ", "").isEmpty) {
      validComment = false;
    } else {
      validComment = true;
    }

    if (!validComment) {
      notifyListeners();
    }

    return validComment;
  }

  AddCommentModel({required this.database});
}
