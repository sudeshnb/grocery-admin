import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grocery_admin/models/state_models/add_coupon_model.dart';
import 'package:grocery_admin/models/data_models/coupon.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/widgets/buttons/default_button.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:grocery_admin/widgets/text_fields/default_text_field.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class AddCoupon extends StatefulWidget {
  final Coupon? coupon;
  final AddCouponModel model;

  AddCoupon._({ this.coupon, required this.model});

  static create(BuildContext context, {Coupon? coupon}) async {
    final database = Provider.of<Database>(context, listen: false);

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Padding(
          padding: MediaQuery.of(context).viewInsets,
        child: ChangeNotifierProvider<AddCouponModel>(
          create: (context) => AddCouponModel(database: database),
          child: Consumer<AddCouponModel>(
            builder: (context, model, _) {
              return AddCoupon._(
                model: model,
                coupon: coupon,
              );
            },
          ),
        ),
        ));
  }

  @override
  _AddCouponState createState() => _AddCouponState();
}

class _AddCouponState extends State<AddCoupon> with TickerProviderStateMixin {
  TextEditingController codeController = TextEditingController();

  FocusNode codeFocus = FocusNode();

  late DateTime expiryDate;

  @override
  void initState() {
    super.initState();
    if (widget.coupon != null) {
      expiryDate = widget.coupon!.expiryDate;

      widget.model.isPercentage =
          (widget.coupon!.type == "percentage") ? true : false;

      codeController = TextEditingController(text: widget.coupon!.code);
      widget.model.value = widget.coupon!.value;
    } else {
      expiryDate = DateTime.now().add(Duration(days: 1));
    }
  }

  @override
  void dispose() {
    super.dispose();
    codeController.dispose();
    codeFocus.dispose();
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
          DefaultTextField(
            controller: codeController,
            focusNode: codeFocus,
            textInputAction: TextInputAction.done,
            textInputType: TextInputType.text,
            labelText: 'Code',
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (value) {},
            error: !widget.model.validCode,
            isLoading: widget.model.isLoading,
            margin: EdgeInsets.only(
              top: 10,
            ),
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          ),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            child: (!widget.model.validCode)
                ? FadeIn(
                    child: Text(
                      'Please enter a valid code',
                      style: themeModel.theme.textTheme.subtitle2!
                          .apply(color: Colors.red),
                    )

                  )
                : SizedBox(),
          ),
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(
              top: 10,
            ),
            decoration: BoxDecoration(
              color: themeModel.secondBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Row(
              children: [
                Text(
                    "Expiry date: ",
                  style: themeModel.theme.textTheme.bodyText1!.apply(
                    color: themeModel.secondTextColor
                  ),
                ),
                Text(
                  expiryDate.toString().substring(0, 10),
                  style: themeModel.theme.textTheme.bodyText1,
                ),
                Spacer(),
                GestureDetector(
                  child: Icon(
                    Icons.edit,
                    color: themeModel.textColor,
                  ),
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)))
                        .then((value) {
                      if (value != null) {
                        expiryDate = value;
                        widget.model.updateWidget();
                      }
                    });
                  },
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Spacer(),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: themeModel.secondBackgroundColor,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                            color: widget.model.isPercentage
                                ? themeModel.accentColor
                                : themeModel.secondBackgroundColor,
                            width: 2)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.percent,
                          color: themeModel.textColor,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                              "Percentage",
                            style: themeModel.theme.textTheme.subtitle1,
                          )

                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    widget.model.changeTypeStatus(true);
                  },
                ),
                Spacer(),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        color: themeModel.secondBackgroundColor,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                            color: !widget.model.isPercentage
                                ? themeModel.accentColor
                                : themeModel.secondBackgroundColor,
                            width: 2)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.dollarSign,
                          color: themeModel.textColor,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            "Fixed Price",
                            style: themeModel.theme.textTheme.subtitle1,
                          )
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    widget.model.changeTypeStatus(false);
                  },
                ),
                Spacer(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: NumberPicker(
              axis: Axis.horizontal,
              value: widget.model.value,
              itemWidth: 70,
              itemHeight: 70,
              minValue: 1,
              maxValue: 100,
              onChanged: widget.model.updateValue,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  border:
                      Border.all(color: themeModel.secondTextColor, width: 2)),
            ),
          ),
          widget.model.isLoading
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(
                  width: double.infinity,
                  child: DefaultButton(
                      widget: Text(
                        (widget.coupon == null) ? "Add" : 'Update',
                        style: themeModel.theme.textTheme.headline3!
                            .apply(color: Colors.white),
                      ),

                      onPressed: () {

                        widget.model.submit(context,
                            code: codeController.text,
                            type: widget.model.isPercentage
                                ? "percentage"
                                : "fixed",
                            value: widget.model.value,
                            expiryDate: expiryDate,
                            path: (widget.coupon == null)
                                ? null
                                : widget.coupon!.path);


                      },
                      color: themeModel.accentColor),
                ),
        ],
      ),
    );
  }
}
