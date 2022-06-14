import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_admin/blocs/shipping_bloc.dart';
import 'package:grocery_admin/models/data_models/shipping_method.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/home/shipping/add_shipping.dart';
import 'package:grocery_admin/widgets/cards/shipping_card.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class Shipping extends StatefulWidget {
  final ShippingBloc bloc;

  const Shipping({required this.bloc});

  static Widget create(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return Provider<ShippingBloc>(
      create: (context) => ShippingBloc(database: database),
      child: Consumer<ShippingBloc>(
        builder: (context, bloc, _) {
          return Shipping(bloc: bloc);
        },
      ),
    );
  }

  @override
  _ShippingState createState() => _ShippingState();
}

class _ShippingState extends State<Shipping> {
  late Stream<List<ShippingMethod>> _shippingStream;

  @override
  void initState() {
    super.initState();

    _shippingStream = widget.bloc.getShippingMethods();
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
            'Shipping Methods',
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
              AddShipping.create(context);
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
                      "Add Shipping",
                      style: themeModel.theme.textTheme.headline3!.apply(
                        color: themeModel.accentColor
                      ),
                    )
                  )
                ],
              ),
            ),
          ),
          StreamBuilder<List<ShippingMethod>>(
              stream: _shippingStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<ShippingMethod> shippingMethods = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width ~/ 180,

                    ),
                    shrinkWrap: true,
                    itemBuilder: (context,position){
                      return FadeIn(
                        duration: Duration(milliseconds: 300),
                        child: ShippingCard(
                            shippingMethod: shippingMethods[position],
                            function: () async {
                              await widget.bloc
                                  .deleteShipping(shippingMethods[position].path!);

                              Navigator.pop(context);
                            }),
                      );

                    },
                    itemCount: shippingMethods.length,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(left: 16, right: 16, top: 20),

                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.only(top: 20),
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
