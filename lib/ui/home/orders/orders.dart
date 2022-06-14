import 'package:flutter/material.dart';
import 'package:grocery_admin/blocs/orders_reader_bloc.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/home/orders/date_filter.dart';
import 'package:grocery_admin/ui/home/orders/orders_reader.dart';
import 'package:provider/provider.dart';
import 'package:grocery_admin/models/state_models/orders_model.dart';

class Orders extends StatefulWidget {
  final OrdersModel model;

  Orders._({required this.model});

  static Widget create(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return ChangeNotifierProvider<OrdersModel>(
      create: (context) => OrdersModel(),
      child: Consumer<OrdersModel>(
        builder: (context, model, _) {
          return Provider<OrdersReaderBloc>(
            create: (context) => OrdersReaderBloc(database: database),
            child: Orders._(
              model: model,
            ),
          );
        },
      ),
    );
  }

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders>{
  String? status;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final bloc = Provider.of<OrdersReaderBloc>(context, listen: false);
    bloc.refresh(10, status ?? "Processing", widget.model.date);
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          shadowColor: themeModel.shadowColor,
          title: Text(
            'Orders',
            style: themeModel.theme.textTheme.headline3!,
          ),
          centerTitle: true,
          backgroundColor: themeModel.secondBackgroundColor,
          leading: Container(),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.view_list,
                  color: themeModel.textColor,
                ),
                onPressed: () {
                  DateFilter.create(context, date: widget.model.date)
                      .then((date) {
                    if (date != null) {
                      if (date == "ALL") {
                        widget.model
                            .changeDateRange(context, status ?? 'Processing');
                      } else {
                        widget.model.changeDateRange(
                            context, status ?? 'Processing', date);
                      }
                    }
                  });
                })
          ],
          bottom: TabBar(
            onTap: (val) {
              if (val == 2) {
                if (status != 'Declined') {
                  status = 'Declined';
                  final bloc =
                      Provider.of<OrdersReaderBloc>(context, listen: false);
                  bloc.refresh(10, status ?? "Processing", widget.model.date);
                }
              } else if (val == 1) {
                if (status != 'Delivered') {
                  status = 'Delivered';
                  final bloc =
                      Provider.of<OrdersReaderBloc>(context, listen: false);
                  bloc.refresh(10, status ?? "Processing", widget.model.date);
                }
              } else {
                if (status != null) {
                  status = null;
                  final bloc =
                      Provider.of<OrdersReaderBloc>(context, listen: false);
                  bloc.refresh(10, status ?? "Processing", widget.model.date);
                }
              }
            },
            tabs: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: Text(
                    'Processing',
                    style: themeModel.theme.textTheme.bodyText2!
                        .apply(color: themeModel.secondTextColor),
                  )),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: Text(
                  'Delivered',
                  style: themeModel.theme.textTheme.bodyText2!
                      .apply(color: themeModel.secondTextColor),
                )

              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: Text(
                  'Declined',
                  style: themeModel.theme.textTheme.bodyText2!
                      .apply(color: themeModel.secondTextColor),
                )

              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ///Processing orders
            OrdersReader.create(),

            ///Delivered orders
            OrdersReader.create(status: 'Delivered'),

            ///Declined orders
            OrdersReader.create(status: 'Declined'),
          ],
        ),
      ),
    );
  }

}
