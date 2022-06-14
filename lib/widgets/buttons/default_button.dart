import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final Widget widget;
  final void Function() onPressed;
  final Color color;
  final bool border;
  final EdgeInsets margin;

  const DefaultButton(
      {Key? key,
      required this.widget,
      required this.onPressed,
      required this.color,
      this.border = false,
      this.margin = const EdgeInsets.only(top: 20)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: TextButton(
        onPressed: onPressed,
        child: Padding(
          padding: EdgeInsets.all(7),
          child: widget,
        ),
        style: TextButton.styleFrom(
            backgroundColor: (border == true) ? Colors.transparent : color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: (border == true)
                  ? BorderSide(color: color, width: 2)
                  : BorderSide.none,
            )),
      ),
    );
  }
}
