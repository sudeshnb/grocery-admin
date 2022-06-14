import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_admin/blocs/orders_reader_bloc.dart';
import 'package:grocery_admin/models/data_models/order.dart';
import 'package:grocery_admin/models/state_models/orders_model.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/widgets/cards/order_card.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class OrdersReader extends  StatefulWidget {
  final String? status;

  final OrdersReaderBloc bloc;

  static Widget create({String? status}) {

    return Consumer<OrdersReaderBloc>(
      builder: (context, bloc, _) {
        return OrdersReader(bloc: bloc, status: status);
      },
    );
  }

  OrdersReader({required this.bloc, this.status});

  @override
  _OrdersReaderState createState() => _OrdersReaderState();
}

class _OrdersReaderState extends State<OrdersReader>{
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final ordersModel = Provider.of<OrdersModel>(context);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return RefreshIndicator(
        onRefresh: ()async{
         await widget.bloc.refresh(10, widget.status ?? 'Processing',ordersModel.date);
        },

        child: NotificationListener(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollEndNotification) {
              if (_scrollController.position.extentAfter == 0) {
                widget.bloc.loadOrders(widget.status ?? 'Processing',10,ordersModel.date);
              }
            }
            return false;
          },
          child: StreamBuilder<List<Order>>(
              stream: widget.bloc.ordersStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Order> orders = snapshot.data!;

                  if (snapshot.data!.length == 0) {
                    return FadeIn(
                      duration: Duration(milliseconds: 300),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'images/nothing_found.svg',
                              width: isPortrait ? width * 0.5 : height * 0.5,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Text(
                                  'Nothing found!',
                                style: themeModel.theme.textTheme.headline3!.apply(
                                  color: themeModel.accentColor
                                ),
                              )

                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemBuilder: (context, position) {
                        return FadeIn(
                          duration: Duration(milliseconds: 300),
                          child: OrderCard(
                            order: orders[position],
                            refresh: widget.bloc.removeOrderLocally,
                          ),
                        );
                      },
                      itemCount: orders.length,
                    );
                  }
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  print(snapshot.stackTrace);
                  return Center(
                    child: SvgPicture.asset(
                      'images/error.svg',
                      width: width * 0.5,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        ));
  }

}
