import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:grocery_admin/helpers/project_configuration.dart';
import 'package:grocery_admin/models/data_models/address.dart';
import 'package:grocery_admin/models/data_models/delivery_boy.dart';
import 'package:grocery_admin/models/data_models/order.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/services/cloud_functions.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class OrderDetailsBloc {
  final String path;
  final Database database;
  final AuthBase auth;

  OrderDetailsBloc(
      {required this.database, required this.path, required this.auth});

  // ignore: close_sinks
  StreamController<bool> itemsController = BehaviorSubject();

  // ignore: close_sinks
  StreamController<bool> paymentController = BehaviorSubject();

  // ignore: close_sinks
  StreamController<bool> addressController = BehaviorSubject();

  // ignore: close_sinks
  StreamController<bool> shippingMethodController = BehaviorSubject();

  // ignore: close_sinks
  StreamController<bool> couponController = BehaviorSubject();

  // ignore: close_sinks
  StreamController<bool> deliveryBoyController = BehaviorSubject();

  // ignore: close_sinks
  StreamController<bool> commentsController = BehaviorSubject();

  //Get order
  Stream<Order> getOrder() {
    print(path);
    return database.getDataFromDocument(path).map((snapshot) => Order.fromMap(
        snapshot.data() as Map<String, dynamic>, snapshot.id, path));
  }

  //Set new order status
  Future<void> updateOrderStatus(
      BuildContext context, String status, Order order) async {
    await database.updateData({'status': status}, path);

    await _sendNotification(
        context, "Your order nº${order.id} is $status", order.id);
  }

  Future<void> setDeliveryBoy(
      BuildContext context, DeliveryBoy deliveryBoy) async {
    if (deliveryBoy.image != null) {
      await database.updateData({
        'delivery_boy': {
          'full_name': deliveryBoy.fullName,
          'email': deliveryBoy.email,
          'image': deliveryBoy.image,
        }
      }, path);
    } else {
      await database.updateData({
        'delivery_boy': {
          'full_name': deliveryBoy.fullName,
          'email': deliveryBoy.email,
        }
      }, path);
    }

    await _sendNotification(
        context, 'You have a new delivery', deliveryBoy.email,
        delivery: true);
  }

  Future<void> removeDeliveryBoy() async {
    await database.updateData({
      'delivery_boy': FieldValue.delete(),
      'delivery_comment': FieldValue.delete(),
    }, path);
  }

  Future<void> removeAdminComment() async {
    await database.updateData({
      'admin_comment': FieldValue.delete(),
    }, path);
  }

  Future<void> removeDeliveryBoyComment() async {
    await database.updateData({
      'delivery_comment': FieldValue.delete(),
    }, path);
  }

  Future<void> _sendNotification(BuildContext context, String msg, String id,
      {bool delivery = false}) async {
    String? token;
    if (delivery) {
      token = await _getDeliveryToken(id);
    } else {
      token = await _getToken();
    }

    if (token != null) {
      try {
        if (ProjectConfiguration.useCloudFunctions) {
          final body = {
            "fcmToken": token,
            "title": delivery ? "New Delivery!" : "New order!",
            "message": msg,
          };

          final cloudFunctions =
              Provider.of<CloudFunctions>(context, listen: false);

          await cloudFunctions.sendNotification(body);
        } else {
          final body = {
            "token": token,
            "title": delivery ? "New Delivery!" : "New order!",
            "message": msg,
          };

          await http.post(Uri.parse(ProjectConfiguration.notificationsApi),
              body: json.encode(body));
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<String?> _getToken() async {
    String uid = path
        .replaceFirst("users/", "")
        .substring(0, path.replaceFirst("users/", "").indexOf("/"));

    print(uid);

    try {
      final snapshot = await database.getFutureDataFromDocument("users/$uid");

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data['token'];
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getDeliveryToken(String email) async {
    try {
      final snapshot =
          await database.getFutureDataFromDocument("delivery_boys/$email");

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data['token'];
    } catch (e) {
      return null;
    }
  }

  Future<void> showMap(Address address) async {
    String stringAddress = address.toString();

    try {
      List<Location> locations = await locationFromAddress(stringAddress);

      final availableMaps = await MapLauncher.installedMaps;

      if (availableMaps.isNotEmpty) {
        await availableMaps.first.showDirections(
          destination:
              Coords(locations.first.latitude, locations.first.longitude),
          destinationTitle: stringAddress,
        );
      } else {
        Fluttertoast.showToast(
            msg: "No available Maps App installed in this device!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Can\'t find this location!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
