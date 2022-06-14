import 'package:flutter/material.dart';
import 'package:grocery_admin/models/data_models/order.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/ui/home/orders/order_details/order_details.dart';
import 'package:provider/provider.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final void Function(Order) refresh;

  const OrderCard({Key? key, required this.order, required this.refresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return ListTile(
      title: Text(
        "Order N:" + order.id,
        style: themeModel.theme.textTheme.headline3,
      ),
      subtitle: Text(
        order.date,
        style: themeModel.theme.textTheme.bodyText1!
            .apply(color: themeModel.secondTextColor),
      ),
      onTap: () {
        OrderDetails.create(context, order.path, order.status).then((value) {
          if (value != null) {
            refresh(order);
          }
        });
      },
    );
  }
}
