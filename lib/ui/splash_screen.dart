import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_admin/helpers/project_configuration.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/landing.dart';
import 'package:grocery_admin/widgets/transparent_image.dart';

class SplashScreen extends StatelessWidget {
  final AuthBase auth;
  final Database database;

  SplashScreen({required this.auth, required this.database});

  Future<void> precacheImages(BuildContext context) async {
    await Future.delayed(Duration(milliseconds: 1500));

    ///Precache images for better performance

    ///Precache png images
    await Future.forEach<String>(ProjectConfiguration.pngImages, (image) async {
      await precacheImage(AssetImage(image), context);
    });

    ///Precache svg images
    await Future.forEach<String>(ProjectConfiguration.svgImages, (image) async {
      await precachePicture(
          ExactAssetPicture(SvgPicture.svgStringDecoder, image), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: precacheImages(context),
        builder: (context, verificationSnapshot) {
          return StreamBuilder<User?>(
              stream: auth.onAuthStateChanged,
              builder: (context, snapshot) {
                if (verificationSnapshot.connectionState ==
                    ConnectionState.done) {
                  ///Check if the user is an admin
                  SchedulerBinding.instance!.addPostFrameCallback((_) {
                    Future.delayed(Duration.zero).then((value) async {
                      if (snapshot.hasData) {
                        try {
                          await database
                              .getFutureCollection("permission_check");
                        } catch (e) {
                          await auth.signOut();
                        }
                      }
                      Landing.create(context);
                    });
                  });
                }

                return Center(
                  child: FadeInImage(
                    image: AssetImage(ProjectConfiguration.logo),
                    placeholder: MemoryImage(kTransparentImage),
                    width: 100,
                    height: 100,
                  ),
                );
              });
        },
      ),
    );
  }
}
