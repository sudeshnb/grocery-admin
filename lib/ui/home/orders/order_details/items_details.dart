import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grocery_admin/models/data_models/order_product_items.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class ItemsDetails extends StatefulWidget {
  final StreamController<bool> controller;
  final List<OrdersProductItem> products;

  ItemsDetails({required this.controller, required this.products});

  @override
  _ItemsDetailsState createState() => _ItemsDetailsState();
}

class _ItemsDetailsState extends State<ItemsDetails>
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
              children: [
                Container(
                  height: 0.5,
                  color: themeModel.secondTextColor,
                ),
                ListTile(
                  leading: Icon(
                    Icons.shopping_cart_outlined,
                    color: themeModel.textColor,
                  ),
                  title: Text(
                    "Items",
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
                    ? FadeIn(
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ///Items
                              Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Padding(
                                    padding: EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text(
                                      '${widget.products.length} item' +
                                          ((widget.products.length == 1)
                                              ? ""
                                              : "s"),
                                      style: themeModel.theme.textTheme.bodyText2,
                                    )),
                              ),
                              Column(
                                children: List.generate(widget.products.length,
                                    (position) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Text(
                                            widget.products[position].title,
                                            style: themeModel
                                                .theme.textTheme.bodyText2,
                                          )),
                                      Expanded(

                                          child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Text(
                                                widget.products[position].quantity,
                                                style: themeModel
                                                    .theme.textTheme.bodyText1!
                                                    .apply(
                                                    color: themeModel
                                                        .secondTextColor),
                                              )
                                          ),),
                                      Expanded(
                                          child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                widget.products[position].price
                                                    .toString() +
                                                    "\$",
                                                style: themeModel
                                                    .theme.textTheme.bodyText2!
                                                    .apply(
                                                    color:
                                                    themeModel.priceColor),
                                              )
                                          ),),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox()
              ],
            );
          }),
    );
  }
}
