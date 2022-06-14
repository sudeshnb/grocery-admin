import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:grocery_admin/helpers/project_configuration.dart';
import 'package:grocery_admin/models/data_models/app_notification.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/services/cloud_functions.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///Initialize Firebase
  await Firebase.initializeApp();

  ///Initialize Storage
  await GetStorage.init();

  ///Initialize Firebase messaging
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  ///Request notifications permission
  await _firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  ///Show foreground notifications
  FirebaseMessaging.onMessage.listen(myBackgroundMessageHandler);

  ///Show background notifications
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  runApp(MyApp());
}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  showNotification(AppNotification.fromMap(message.data));
}

///Show notification
Future<void> showNotification(AppNotification notification) async {}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ///Check dark mode
    GetStorage storage = GetStorage();
    bool isDark = false;
    if (storage.hasData('isDark')) {
      isDark = storage.read('isDark') ?? false;
    }

    final providers = [
      ///Theme provider
      ChangeNotifierProvider<ThemeModel>(
          create: (context) =>
              ThemeModel(theme: isDark ? ThemeModel.dark : ThemeModel.light)),

      ///Auth provider
      Provider<AuthBase>(create: (context) => Auth()),

      ///Database(Firestore) provider
      Provider<Database>(create: (context) => FirestoreDatabase()),
    ];

    ///If cloud functions are activated, add his provider
    if (ProjectConfiguration.useCloudFunctions) {
      providers
          .add(Provider<CloudFunctions>(create: (context) => CloudFunctions()));
    }

    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeModel>(
        builder: (context, model, _) {
          final auth = Provider.of<AuthBase>(context, listen: false);
          final database = Provider.of<Database>(context, listen: false);

          return MaterialApp(
            theme: model.theme,
            home: SplashScreen(
              auth: auth,
              database: database,
            ),
            title: "Grocery Admin",
          );
        },
      ),
    );
  }
}
