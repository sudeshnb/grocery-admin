import 'package:flutter/material.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:provider/provider.dart';

class SettingsCard extends StatelessWidget {


  final String title;
  final void Function() onPressed;
  final Widget widget;
  final Color? color;
  const SettingsCard({Key? key,
    required this.title,
    required this.onPressed,
    required this.widget,
     this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return GestureDetector(
      child: Container(
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: themeModel.secondBackgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                  blurRadius: 2,
                  offset: Offset(0, 5),
                  color: themeModel.shadowColor)
            ]),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget,
              Padding(
                padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Text(
                    title,
                  style: themeModel.theme.textTheme.subtitle1!.apply(
                    color:  color ?? themeModel.textColor
                  ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center
                )



              ),
            ],
          ),
        ),
      ),
      onTap: onPressed,
    );
  }
}
