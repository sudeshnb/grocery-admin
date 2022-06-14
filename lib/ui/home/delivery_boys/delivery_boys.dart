import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_admin/models/data_models/delivery_boy.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/home/delivery_boys/add_delivery_boy.dart';
import 'package:grocery_admin/widgets/cards/delivery_boy_card.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';
import 'package:grocery_admin/blocs/delivery_boys_bloc.dart';

// ignore: must_be_immutable
class DeliveryBoys extends StatefulWidget {
  final DeliveryBoysBloc bloc;
  final bool selectAction;

  DeliveryBoys._({required this.bloc, this.selectAction=false});

  static Future<DeliveryBoy?> create(BuildContext context,
      {bool selectAction = false}) {
    final database = Provider.of<Database>(context, listen: false);

    return Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return Provider<DeliveryBoysBloc>(
        create: (context) => DeliveryBoysBloc(database: database),
        child: Consumer<DeliveryBoysBloc>(
          builder: (context, bloc, _) {
            return DeliveryBoys._(
              bloc: bloc,
              selectAction: selectAction,
            );
          },
        ),
      );
    }));
  }

  @override
  _DeliveryBoysState createState() => _DeliveryBoysState();
}

class _DeliveryBoysState extends State<DeliveryBoys> {




  late Stream<List<DeliveryBoy>> _deliveryBoysStream;

  @override
  void initState() {
    super.initState();

    _deliveryBoysStream=widget.bloc.getDeliveryBoys();


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
        title: Text(
            widget.selectAction ? 'Select a Delivery Boy' : 'Delivery Boys',
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
            Navigator.pop(context);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddDeliveryBoy.create(context);
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<List<DeliveryBoy>>(
        stream: _deliveryBoysStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DeliveryBoy> deliveryBoys = snapshot.data!;

            if (deliveryBoys.isEmpty) {
              return FadeIn(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'images/no_delivery_found.svg',
                        width: isPortrait ? width * 0.5 : height * 0.5,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                            'No delivery boy found!',
                          style: themeModel.theme.textTheme.headline3!.apply(
                            color: themeModel.accentColor
                          ),
                        )

                      ),
                    ],
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 200),
                itemBuilder: (context, position) {
                  return FadeIn(
                    child: DeliveryBoyCard(
                        deliveryBoy: deliveryBoys[position],
                        selectAction: widget.selectAction),
                  );
                },
                itemCount: deliveryBoys.length,
              );
            }
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
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
