import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grocery_admin/models/data_models/shipping_method.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class ShippingMethodDetails extends StatefulWidget {
  final StreamController<bool> controller;
  final ShippingMethod shippingMethod;

  ShippingMethodDetails(
      {required this.controller, required this.shippingMethod});

  @override
  _ShippingMethodDetailsState createState() => _ShippingMethodDetailsState();
}

class _ShippingMethodDetailsState extends State<ShippingMethodDetails>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      child: StreamBuilder<bool>(
        stream: widget.controller.stream,
        initialData: false,
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 0.5,
                color: themeModel.secondTextColor,
              ),
              ListTile(
                leading: Icon(
                  Icons.local_shipping_outlined,
                  color: themeModel.textColor,
                ),
                title: Text(
                  "Shipping method",
                  style: themeModel.theme.textTheme.headline3,
                ),
                onTap: () {
                  widget.controller.add(!snapshot.data!);
                },
                contentPadding:
                    EdgeInsets.only(right: 20, bottom: 5, top: 5, left: 20),
                trailing: Icon(
                  (!snapshot.data!)
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: themeModel.textColor,
                ),
              ),
              (snapshot.data!)
                  ? Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: FadeIn(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///Shipping title
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                  'Shipping title:',
                                style: themeModel.theme.textTheme.bodyText2,
                              )

                            ),
                            Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  widget.shippingMethod.title,
                                  style: themeModel.theme.textTheme.bodyText1!
                                      .apply(color: themeModel.secondTextColor),
                                )),

                            ///Shipping price
                            Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  'Price:',
                                  style: themeModel.theme.textTheme.bodyText2,
                                )),
                            Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  widget.shippingMethod.price.toString() + "\$",
                                  style: themeModel.theme.textTheme.bodyText1!
                                      .apply(color: themeModel.priceColor),
                                )),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
              Container(
                height: 0.5,
                color: themeModel.secondTextColor,
              ),
            ],
          );
        },
      ),
    );
  }
}
