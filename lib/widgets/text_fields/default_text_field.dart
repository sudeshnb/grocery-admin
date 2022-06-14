import 'package:flutter/material.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:provider/provider.dart';

class DefaultTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final String labelText;
  final Function(String)? onSubmitted;
  final bool enabled;
  final bool error;
  final bool isLoading;
  final Function(String)? onChanged;
  final int minLines;
  final int? maxLines;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final bool changeBackColor;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  const DefaultTextField({
    required this.controller,
    required this.focusNode,
    required this.textInputType,
    required this.textInputAction,
    required this.labelText,
    required this.error,
    required this.isLoading,
    this.onChanged,
    this.onSubmitted,
    this.padding = const EdgeInsets.all(10),
    this.margin = const EdgeInsets.all(0),
    this.changeBackColor = false,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.enabled=true,
    this.maxLines = 1,
    this.minLines = 1
  });

  @override
  Widget build(BuildContext context) {
    final themeModel=Provider.of<ThemeModel>(context);

    Color backColor = (changeBackColor)
        ? themeModel.backgroundColor
        : themeModel.secondBackgroundColor;
    return Container(
      decoration: BoxDecoration(
        color: enabled ? backColor : backColor.withOpacity(0.4),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        border: Border.all(
            width: 2, color: error ? Colors.red : Colors.transparent),
      ),
      padding: padding,
      margin: margin,
      child: TextField(
        obscureText: obscureText,
        maxLines: maxLines,
        minLines: minLines,
        enabled: enabled && !isLoading,
        keyboardType: textInputType,
        textInputAction: textInputAction,
        controller: controller,
        focusNode: focusNode,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            labelText: labelText,
            contentPadding: EdgeInsets.only(left: 20, right: 20)),
      ),
    );
  }
}
