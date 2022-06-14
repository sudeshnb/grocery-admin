import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_admin/blocs/coupons_bloc.dart';
import 'package:grocery_admin/models/data_models/coupon.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/home/coupons/add_coupon.dart';
import 'package:grocery_admin/widgets/cards/coupon_card.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class Coupons extends StatefulWidget {
  final CouponsBloc bloc;

  Coupons._({required this.bloc});

  static Widget create(BuildContext context) {
    final database = Provider.of<Database>(context);
    return Provider<CouponsBloc>(
      create: (context) => CouponsBloc(database: database),
      child: Consumer<CouponsBloc>(
        builder: (context, bloc, _) {
          return Coupons._(
            bloc: bloc,
          );
        },
      ),
    );
  }

  @override
  _CouponsState createState() => _CouponsState();
}

class _CouponsState extends State<Coupons>{
  late Stream<List<Coupon>> _couponsStream;

  @override
  void initState() {
    super.initState();

    _couponsStream = widget.bloc.getCoupons();
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        shadowColor: themeModel.shadowColor,
        title: Text(
          'Coupons',
          style: themeModel.theme.textTheme.headline3,
        ),
        centerTitle: true,
        backgroundColor: themeModel.secondBackgroundColor,
        leading: Container(),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 80),
        children: [
          GestureDetector(
            onTap: () {
              AddCoupon.create(context);
            },
            child: Container(
              margin: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
              ),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: themeModel.secondBackgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 2,
                        offset: Offset(0, 5),
                        color: themeModel.shadowColor)
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: themeModel.accentColor,
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Add Coupon",
                        style: themeModel.theme.textTheme.headline3!
                            .apply(color: themeModel.accentColor),
                      ))
                ],
              ),
            ),
          ),
          StreamBuilder<List<Coupon>>(
              stream: _couponsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Coupon> coupons = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width ~/ 180,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(left: 16, right: 16, top: 20),
                    itemBuilder: (context,position){
                      return   FadeIn(
                        duration: Duration(milliseconds: 300),
                        child: CouponCard(
                            coupon: coupons[position],
                            function: () async {
                              await widget.bloc.deleteCoupon(coupons[position]);

                              Navigator.pop(context);
                            }),
                      );
                    },
                    itemCount: coupons.length,
                  );
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: SvgPicture.asset(
                        'images/error.svg',
                        width: isPortrait ? width * 0.5 : height * 0.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }

}
