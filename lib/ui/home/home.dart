import 'package:flutter/material.dart';
import 'package:grocery_admin/models/state_models/bottom_navigation_bar_model.dart';
import 'package:grocery_admin/models/state_models/home_model.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/home/bottom_navigation_bar_home.dart';
import 'package:grocery_admin/ui/home/coupons/coupons.dart';
import 'package:grocery_admin/ui/home/orders/orders.dart';
import 'package:grocery_admin/ui/home/products/products.dart';
import 'package:grocery_admin/ui/home/settings/settings.dart';
import 'package:grocery_admin/ui/home/shipping/shipping.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final HomeModel model;

  Home({required this.model});

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    final database = Provider.of<Database>(context);

    return MultiProvider(
      providers: [
        Provider<HomeModel>(
          create: (context) => HomeModel(auth: auth, database: database),
        ),
        ChangeNotifierProvider<BottomNavigationBarModel>(
          create: (context) => BottomNavigationBarModel(),
        ),

      ],
      child: Consumer<HomeModel>(
        builder: (context, model, _) {
          return Home(
            model: model,
          );
        },
      ),
    );
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          key: Key("home"),
          extendBody: true,
          body: PageView(
            controller: widget.model.pageController,
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              Products.create(context),
              Shipping.create(context),
              Coupons.create(context),
              Orders.create(context),
              Settings.create(context),
            ],
            onPageChanged: (value) {
              final bottomModel =
                  Provider.of<BottomNavigationBarModel>(context, listen: false);

              bottomModel.goToPage(value);
            },
          ),
          bottomNavigationBar: Consumer<BottomNavigationBarModel>(
            builder: (context, model, _) {
              return BottomNavigationBarHome(
                model: model,
              );
            },
          ),
        ),
        onWillPop: () async {
          return widget.model.onPop();
        });
  }

  @override
  void initState() {
    super.initState();
    ///Add user token to receive notifications
    widget.model.checkNotificationToken();
  }
}
