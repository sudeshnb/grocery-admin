import 'package:flutter/material.dart';
import 'package:grocery_admin/models/state_models/change_password_model.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/auth.dart';
import 'package:grocery_admin/widgets/buttons/default_button.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:grocery_admin/widgets/text_fields/email_text_field.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  final ChangePasswordModel model;

  const ChangePassword({required this.model});

  static create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: ChangeNotifierProvider<ChangePasswordModel>(
                create: (context) => ChangePasswordModel(auth: auth),
                child: Consumer<ChangePasswordModel>(
                  builder: (context, model, _) {
                    return ChangePassword(model: model);
                  },
                ),
              ),
            ));
  }

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword>
    with TickerProviderStateMixin {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
          color: themeModel.backgroundColor,
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
          ///Password field
          EmailTextField(
            textEditingController: passwordController,
            focusNode: passwordFocus,
            textInputAction: TextInputAction.next,
            textInputType: TextInputType.text,
            labelText: 'New password',
            iconData: Icons.lock_outline,
            onSubmitted: (value) {},
            error: !widget.model.validPassword,
            isLoading: widget.model.isLoading,
            obscureText: true,
          ),

          AnimatedSize(
            duration: Duration(milliseconds: 300),
            child: (!widget.model.validPassword)
                ? FadeIn(
                    child: Text(
                    'Please enter a valid password : don\'t forget numbers, special characters(@, # ...), capital letters',
                    style: themeModel.theme.textTheme.subtitle2!
                        .apply(color: Colors.red),
                  ))
                : SizedBox(),
          ),

          ///Confirm password field
          EmailTextField(
            textEditingController: confirmPasswordController,
            focusNode: confirmPasswordFocus,
            textInputAction: TextInputAction.done,
            textInputType: TextInputType.text,
            labelText: 'Confirm new password',
            iconData: Icons.lock_outline,
            onSubmitted: (value) {
              widget.model.submit(context, passwordController.text,
                  confirmPasswordController.text);
            },
            error: !widget.model.validConfirmPassword,
            isLoading: widget.model.isLoading,
            obscureText: true,
          ),

          AnimatedSize(
            duration: Duration(milliseconds: 300),
            child: (!widget.model.validConfirmPassword)
                ? FadeIn(
                    child: Text(
                      'Please enter a valid password : don\'t forget numbers, special characters(@, # ...), capital letters',
                      style: themeModel.theme.textTheme.subtitle2!
                          .apply(color: Colors.red),
                    ),
                  )
                : SizedBox(),
          ),

          ///Submit button <--> loading indicator
          (widget.model.isLoading)
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(
                  width: double.infinity,
                  child: DefaultButton(
                      widget: Text(
                        'Change Password',
                        style: themeModel.theme.textTheme.headline3!
                            .apply(color: Colors.white),
                      ),
                      onPressed: () {
                        widget.model.submit(context, passwordController.text,
                            confirmPasswordController.text);
                      },
                      color: themeModel.accentColor),
                ),
        ],
      ),
    );
  }
}
