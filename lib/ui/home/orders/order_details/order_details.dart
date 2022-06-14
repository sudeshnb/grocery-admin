import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_admin/blocs/order_details_bloc.dart';
import 'package:grocery_admin/models/data_models/order.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/home/orders/order_details/comments_details/comments_details.dart';
import 'package:grocery_admin/ui/home/orders/order_details/coupon_details.dart';
import 'package:grocery_admin/ui/home/orders/order_details/delivery_boy_details.dart';
import 'package:grocery_admin/ui/home/orders/order_details/items_details.dart';
import 'package:grocery_admin/ui/home/orders/order_details/payment_details.dart';
import 'package:grocery_admin/ui/home/orders/order_details/address_details.dart';
import 'package:grocery_admin/ui/home/orders/order_details/shipping_method_details.dart';
import 'package:grocery_admin/widgets/buttons/default_button.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class OrderDetails extends StatefulWidget {
  final OrderDetailsBloc bloc;
  final String initialStatus;

  OrderDetails._({required this.bloc,required this.initialStatus});

  static Future<bool?> create(BuildContext context, String path,String initialStatus) {
    final database = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);

    return Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => Provider<OrderDetailsBloc>(
                  create: (context) =>
                      OrderDetailsBloc(database: database, path: path,auth: auth),
                  child: Consumer<OrderDetailsBloc>(
                    builder: (context, bloc, _) {
                      return OrderDetails._(bloc: bloc,
                        initialStatus: initialStatus,
                      );
                    },
                  ),
                )));
  }

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {








  late Stream<Order> _orderStream;
  @override
  void initState() {
    super.initState();

    _orderStream=widget.bloc.getOrder();


  }


   String? status;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final themeModel = Provider.of<ThemeModel>(context);

    return WillPopScope(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: themeModel.theme.textTheme.headline3,
        ),
        backgroundColor: themeModel.secondBackgroundColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: themeModel.textColor,
          ),
          onPressed: () {
            if(status!=widget.initialStatus){
              Navigator.pop(context,true);
            }else{
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: StreamBuilder<Order>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Order order = snapshot.data!;

            status=order.status;
            return ListView(
              padding: EdgeInsets.all(0),
              children: [
                ///Order number and date
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Order №${order.id}',
                        style: themeModel.theme.textTheme.headline3,
                      ),
                      Spacer(),
                      Text(
                        order.date,
                        style: themeModel.theme.textTheme.bodyText1!
                            .apply(color: themeModel.secondTextColor),
                      ),
                    ],
                  ),
                ),

                ///Status
                Padding(
                  padding:
                  EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Status: ",
                        style: themeModel.theme.textTheme.headline3,
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (order.status == 'Delivered')
                                ? Colors.green
                                : (order.status == 'Declined')
                                ? Colors.red
                                : Colors.orange),
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(right: 10),
                        child: Icon(
                          (order.status == 'Delivered')
                              ? Icons.done
                              : (order.status == 'Declined')
                              ? Icons.clear
                              : Icons.pending_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        order.status,
                        style: themeModel.theme.textTheme.headline3!.apply(
                            color: (order.status == 'Delivered')
                                ? Colors.green
                                : (order.status == 'Declined')
                                ? Colors.red
                                : Colors.orange),
                      ),
                    ],
                  ),
                ),

                ///Items
                ItemsDetails(
                  controller: widget.bloc.itemsController,
                  products: order.products,
                ),

                ///Payment Details
                PaymentDetails(
                  controller: widget.bloc.paymentController,
                  paymentMethod: order.paymentMethod,
                  paymentReference: order.paymentReference,
                ),

                ///Address
                AddressDetails(
                  controller: widget.bloc.addressController,
                  address: order.address,
                ),

                ///Shipping Method
                ShippingMethodDetails(
                  controller: widget.bloc.shippingMethodController,
                  shippingMethod: order.shippingMethod,
                ),

                ///Coupon
                (order.coupon == null)
                    ? SizedBox()
                    : CouponDetails(
                    controller: widget.bloc.couponController,
                    coupon: order.coupon!),

                ///Delivery Boy
                DeliveryBoyDetails(
                  controller: widget.bloc.deliveryBoyController,
                  deliveryBoy: order.deliveryBoy,
                  status: order.status,
                ),

                ///Comments
                CommentsDetails(
                  controller: widget.bloc.commentsController,
                  path: order.path,
                  adminComment: order.adminComment,
                  deliveryComment: order.deliveryComment,
                ),

                ///Total
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Text(
                            'Total Amount:',
                            style: themeModel.theme.textTheme.headline3,
                          )),
                      Expanded(
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              order.total.toString() + '\$',
                              style: themeModel.theme.textTheme.headline3!
                                  .apply(color: themeModel.priceColor),
                            )),
                      )
                    ],
                  ),
                ),

                /// Accept/In process/Decline buttons
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DefaultButton(
                        color: Colors.red,
                        widget: Text(
                          "Decline",
                          style: themeModel.theme.textTheme.headline3!
                              .apply(color: Colors.white),
                        ),
                        onPressed: () {
                          if (order.status != 'Declined') {
                            widget.bloc.updateOrderStatus(context,'Declined', order);
                          }
                        },
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                      ),
                      DefaultButton(
                        color: Colors.orange,
                        widget: Text(
                          "In Process",
                          style: themeModel.theme.textTheme.headline3!
                              .apply(color: Colors.white),
                        ),
                        onPressed: () {
                          if (order.status != 'Processing') {
                            widget.bloc.updateOrderStatus(context,'Processing', order);
                          }
                        },
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                      ),
                      DefaultButton(
                        color: Colors.green,
                        widget: Text(
                          "Deliver",
                          style: themeModel.theme.textTheme.headline3!
                              .apply(color: Colors.white),
                        ),
                        onPressed: () {
                          if (order.status != 'Delivered') {
                            widget.bloc.updateOrderStatus(context,'Delivered', order);
                          }
                        },
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                      ),
                    ],
                  ),
                )
              ],
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return FadeIn(
              duration: Duration(milliseconds: 300),
              child: Center(
                child: SvgPicture.asset(
                  'images/error.svg',
                  width: width * 0.5,
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    ),
        onWillPop: ()async{

          if(status!=widget.initialStatus){
            Navigator.pop(context,true);
          }else{
            Navigator.pop(context);
          }

          return false;
        });
  }
}
