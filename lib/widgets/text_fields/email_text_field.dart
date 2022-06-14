import 'package:flutter/material.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:provider/provider.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final String labelText;
  final IconData iconData;
  final Function onSubmitted;
  final bool error;
  final bool isLoading;
  final bool obscureText;

  const EmailTextField(
      {required this.textEditingController,
      required this.focusNode,
      required this.textInputAction,
      required this.textInputType,
      required this.labelText,
      required this.iconData,
      required this.onSubmitted,
      required this.error,
      required this.isLoading,
      this.obscureText = false});

  @override
  Widget build(BuildContext context) {

    final themeModel=Provider.of<ThemeModel>(context);

    return Container(
      margin: EdgeInsets.only(
        top: 10,
      ),
      padding:const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: themeModel.secondBackgroundColor,
        borderRadius:const BorderRadius.all(Radius.circular(15)),
        border: Border.all(
            width: 2, color: error ? Colors.red : Colors.transparent),

      ),
      child: TextField(
        enabled: !isLoading,
        obscureText: obscureText,
        controller: textEditingController,
        focusNode: focusNode,
        textInputAction: textInputAction,
        keyboardType: textInputType,
        onSubmitted: (value) {
          onSubmitted();
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          labelText: labelText,
          icon: Icon(iconData),
        ),
      ),
    );
  }
}
