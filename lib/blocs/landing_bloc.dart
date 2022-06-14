import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:rxdart/rxdart.dart';

class LandingBloc {
  final AuthBase auth;
  final Database database;

  bool _verifiedUser = true;
  bool isError = false;

  LandingBloc({required this.auth, required this.database});

  Stream<User?> getSignedUser(BuildContext context) {
    Stream<User?> onAuthStateChanged = auth.onAuthStateChanged;
    // ignore: close_sinks
    StreamController<User?> authController = BehaviorSubject();
    onAuthStateChanged.listen((user) {
      isError = false;

      if (user == null) {
        if (_verifiedUser) {
          _verifiedUser = false;
        }
        authController.add(null);
      } else {
        ///If user is verified redirect to homepage
        if (_verifiedUser) {
          authController.add(user);
        } else {
          ///Check if user is an admin
          _verifiedUser = false;

          Future.delayed(Duration.zero).then((value) async {
            try {
              await database.getFutureCollection("permission_check");

              authController.add(user);

              _verifiedUser = true;
            } catch (e) {
              await auth.signOut();

              isError = true;

              authController.add(null);
            }
          });
        }
      }
    });

    return authController.stream;
  }
}
