import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grocery_admin/blocs/landing_bloc.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/transitions/FadeRoute.dart';
import 'package:grocery_admin/ui/home/home.dart';
import 'package:grocery_admin/ui/sign_in.dart';
import 'package:grocery_admin/widgets/dialogs/error_dialog.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class Landing extends StatefulWidget {
  final LandingBloc bloc;

  Landing({required this.bloc});

  static create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    Navigator.pushReplacement(
        context,
        FadeRoute(
            page: Provider<LandingBloc>(
          create: (context) => LandingBloc(auth: auth, database: database),
          child: Consumer<LandingBloc>(builder: (context, bloc, _) {
            return Landing(bloc: bloc);
          }),
        )));
  }

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  late Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = widget.bloc.getSignedUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: _authStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FadeIn(
              child: Home.create(context),
            );
          } else {
            ///If there is an error show error Dialog
            if (widget.bloc.isError) {
              SchedulerBinding.instance!.addPostFrameCallback((_) {
                showDialog(
                    context: context,
                    builder: (context) =>const ErrorDialog(
                        message: "You are not the admin!"));
              });
            }

            return FadeIn(
              child: SignIn.create(context),
            );
          }
        });
  }
}
