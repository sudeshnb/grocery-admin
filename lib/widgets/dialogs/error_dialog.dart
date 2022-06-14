import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/widgets/buttons/default_button.dart';

import 'package:provider/provider.dart';

class ErrorDialog extends StatelessWidget {
  final String message;
  const ErrorDialog({

    required this.message
});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context, listen: false);

    double height = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            borderRadius:const BorderRadius.all(Radius.circular(15)),
            color: themeModel.backgroundColor),
        padding:const EdgeInsets.all(20),
        child: Wrap(
          children: [
            Align(
              alignment: Alignment.center,
              child: SvgPicture.asset(
                "images/state_images/error.svg",
                height: height * 0.25,
              ),
            ),
            Padding(
              padding:const EdgeInsets.only(top: 10),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(message,
                    style: themeModel.theme.textTheme.headline3,
                    textAlign: TextAlign.center,)),
            ),
            Align(
              alignment: Alignment.center,
              child: DefaultButton(
                  widget: Text('OK',
                    style: themeModel.theme.textTheme.headline3!.apply(
                        color: Colors.white
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
