import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_admin/models/state_models/settings_model.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/home/categories/categories.dart';
import 'package:grocery_admin/ui/home/delivery_boys/delivery_boys.dart';
import 'package:grocery_admin/ui/home/settings/update_info.dart';
import 'package:grocery_admin/ui/home/settings/upload_image.dart';
import 'package:grocery_admin/widgets/cards/settings_card.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:grocery_admin/widgets/transparent_image.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  final SettingsModel model;

  Settings._({required this.model});

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context);
    final database = Provider.of<Database>(context);

    return ChangeNotifierProvider<SettingsModel>(
      create: (context) => SettingsModel(auth: auth, database: database),
      child: Consumer<SettingsModel>(
        builder: (context, model, _) {
          return Settings._(model: model);
        },
      ),
    );
  }

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {


  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    double width = MediaQuery.of(context).size.width;

    print(widget.model.displayName);
    return Scaffold(
      body: ListView(
        children: [
          ///Profile information
          Container(
            margin: EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: themeModel.secondBackgroundColor,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 30,
                      offset: Offset(0, 5),
                      color: themeModel.shadowColor)
                ]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    UploadImage.create(context).then((value) {
                      if (value ?? false) {
                        widget.model.updateWidget();
                      }
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: (widget.model.profileImage != null)
                          ? NetworkImage(widget.model.profileImage!)
                          : AssetImage('images/profile.png') as ImageProvider,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(child: GestureDetector(
                  onTap: () {
                    UpdateInfo.create(context).then((value) {
                      if (value != null) {
                        widget.model.updateWidget();
                      }
                    });
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 2),
                            child: Text(
                              widget.model.displayName,
                              style: themeModel.theme.textTheme.headline3,
                            )),
                        Text(
                          widget.model.email,
                          style: themeModel.theme.textTheme.bodyText1!
                              .apply(color: themeModel.secondTextColor),
                        )
                      ],
                    ),
                  ),
                )),
                IconButton(
                  onPressed: () {
                    UpdateInfo.create(context).then((value) {
                      if (value != null) {
                        widget.model.updateWidget();
                      }
                    });
                  },
                  icon: Icon(
                    Icons.edit,
                    color: themeModel.textColor,
                  ),
                ),
              ],
            ),
          ),

          GridView.count(
              crossAxisCount: (width ~/ 120),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 80),
              children: [
                SettingsCard(
                    title: "Categories",
                    onPressed: () {
                      Categories.create(context);
                    },
                    widget: FadeIn(
                      child: SvgPicture.asset(
                        'images/category.svg',
                        height: 40,
                      ),
                    ),
                    color: themeModel.textColor),
                SettingsCard(
                  title: "Delivery",
                  onPressed: () {
                    DeliveryBoys.create(context);
                  },
                  widget: FadeIn(
                    child: SvgPicture.asset(
                      'images/delivery_boy.svg',
                      height: 40,
                    ),
                  ),
                  color: themeModel.textColor,
                ),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: themeModel.secondBackgroundColor,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 2,
                              offset: Offset(0, 5),
                              color: themeModel.shadowColor)
                        ]),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                              padding:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: Text('Dark mode',
                                  style: themeModel.theme.textTheme.subtitle1!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center)),
                          Switch(
                            activeColor: themeModel.accentColor,
                            value:
                                themeModel.theme.brightness == Brightness.dark,
                            onChanged: (value) {
                              themeModel.updateTheme();
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    themeModel.updateTheme();
                  },
                ),
                SettingsCard(
                    title: "Logout",
                    onPressed: () async {

                     await widget.model.signOut();
                    },
                    widget: Icon(
                      Icons.exit_to_app,
                      color: Colors.red,
                      size: 40,
                    ),
                    color: Colors.red)
              ]),
        ],
      ),
    );

  }


}
