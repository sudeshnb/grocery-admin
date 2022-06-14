import 'package:grocery_admin/models/data_models/address.dart';
import 'package:grocery_admin/models/data_models/comment.dart';
import 'package:grocery_admin/models/data_models/coupon.dart';
import 'package:grocery_admin/models/data_models/delivery_boy.dart';
import 'package:grocery_admin/models/data_models/order_product_items.dart';
import 'package:grocery_admin/models/data_models/shipping_method.dart';

class Order {
  final String id;
  final List<OrdersProductItem> products;
  final ShippingMethod shippingMethod;
  final num orderPrice;
  final String status;
  final String date;
  final String path;
  final Address address;
  final String? paymentReference;
  final String paymentMethod;
  final Coupon? coupon;
  final num total;
  final DeliveryBoy? deliveryBoy;
  final Comment? deliveryComment;
  final String? adminComment;

  factory Order.fromMap(Map data, String id, String path) {

    return Order(
      id: id,
      total: num.parse(data['total'].toString()),
      paymentReference: data["payment_reference"],
      paymentMethod: data["payment_method"] ?? "Cash in Delivery",
      date: data['date'],
      products: OrdersProductItem.fromMap(data['products']),
      shippingMethod: ShippingMethod(
        title: data['shipping_method']['title'],
        price: num.parse(data['shipping_method']['price'].toString()),
      ),
      address: Address.fromMap(data['shipping_address']),
      orderPrice: num.parse(data['order'].toString()),
      status: data['status'] ?? "Processing",
      adminComment: data['admin_comment'],
      deliveryComment: data['delivery_comment']!=null
          ? Comment.fromMap(data['delivery_comment'])
          : null,
      path: path,
      coupon:
          data['coupon']!=null ? Coupon.fromMap(data['coupon']) : null,
      deliveryBoy: data['delivery_boy']!=null
          ? DeliveryBoy.fromMap(data['delivery_boy'])
          : null,
    );
  }

  Order(
      {required this.id,
      required this.date,
      required this.products,
      required this.paymentMethod,
      required this.paymentReference,
      required this.shippingMethod,
      required this.orderPrice,
      required this.status,
      required this.path,
      required this.address,
      required this.total,
      this.deliveryComment,
      this.adminComment,
      this.coupon,
      this.deliveryBoy});
}
