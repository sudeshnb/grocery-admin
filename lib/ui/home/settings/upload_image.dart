import 'package:flutter/material.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/models/state_models/upload_image_model.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/widgets/transparent_image.dart';
import 'package:provider/provider.dart';

class UploadImage extends StatelessWidget {
  final UploadImageModel model;

  const UploadImage({required this.model});

  static Future<bool?> create(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);

    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Provider<UploadImageModel>(
          create: (context) => UploadImageModel(auth: auth),
          child: Consumer<UploadImageModel>(builder: (context, model, _) {
            return UploadImage(model: model);
          }),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return Container(
      padding: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          color: themeModel.secondBackgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                blurRadius: 30,
                offset: Offset(0, 5),
                color: themeModel.shadowColor)
          ]),
      child: Wrap(
        children: [
          ///View profile image
          (model.profileImage != null)
              ? ListTile(
            title: Text(
                'View image',
              style: themeModel.theme.textTheme.bodyText1,
            ),
            leading: Icon(
              Icons.image,
              color: themeModel.textColor,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              color: themeModel.textColor,
              size: 15,
            ),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: FadeInImage(
                        placeholder:  MemoryImage(kTransparentImage),
                        image: NetworkImage(model.profileImage!),
                        fit: BoxFit.cover,
                      ),
                    );
                  });
            },
          )
              : SizedBox(),

          ///Upload a new image
          ListTile(
            title: Text(
                'Upload a new image',
              style: themeModel.theme.textTheme.bodyText1,
            ),

            leading: Icon(
              Icons.edit,
              color: themeModel.textColor,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: themeModel.textColor,
            ),
            onTap: () async {
              model.uploadImage().then((value) {
                Navigator.pop(context, true);
              });

            },
          ),
        ],
      ),
    );
  }
}