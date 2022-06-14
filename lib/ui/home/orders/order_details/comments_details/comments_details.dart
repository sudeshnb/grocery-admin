import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grocery_admin/blocs/order_details_bloc.dart';
import 'package:grocery_admin/models/data_models/comment.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/ui/home/orders/order_details/comments_details/add_comment.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:grocery_admin/widgets/transparent_image.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CommentsDetails extends StatefulWidget {
  final StreamController<bool> controller;
  String? adminComment;
  final Comment? deliveryComment;
  final String path;

  CommentsDetails(
      {required this.controller,
      required this.path,
      this.adminComment,
      this.deliveryComment});

  @override
  _CommentsDetailsState createState() => _CommentsDetailsState();
}

class _CommentsDetailsState extends State<CommentsDetails>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      child: StreamBuilder<bool>(
        stream: widget.controller.stream,
        initialData: false,
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(
                  Icons.comment,
                  color: themeModel.textColor,
                ),
                title: Text(
                  "Comments",
                  style: themeModel.theme.textTheme.headline3,
                ),
                onTap: () {
                  widget.controller.add(!snapshot.data!);
                },
                contentPadding:
                    EdgeInsets.only(right: 20, bottom: 5, top: 5, left: 20),
                trailing: Icon(
                  (!snapshot.data!)
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: themeModel.textColor,
                ),
              ),
              (snapshot.data!)
                  ? Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 20),
                      child: FadeIn(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///Admin comment
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 5, left: 20, right: 20),
                              child: Text(
                                'Admin Comment:',
                                style: themeModel.theme.textTheme.bodyText2,
                              ),
                            ),
                            (widget.adminComment != null)
                                ? ListTile(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    onTap: () {
                                      AddComment.create(context,
                                          path: widget.path,
                                          comment: widget.adminComment!);
                                    },
                                    trailing: Wrap(
                                      children: [
                                        IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: themeModel.textColor,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              AddComment.create(context,
                                                  path: widget.path,
                                                  comment:
                                                      widget.adminComment!);
                                            }),
                                        IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: themeModel.textColor,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              final bloc =
                                                  Provider.of<OrderDetailsBloc>(
                                                      context,
                                                      listen: false);
                                              await bloc.removeAdminComment();
                                            }),
                                      ],
                                    ),
                                    title: Text(
                                      widget.adminComment!,
                                      style: themeModel
                                          .theme.textTheme.bodyText1!
                                          .apply(
                                              color:
                                                  themeModel.secondTextColor),
                                    ),
                                  )
                                : ListTile(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    onTap: () {
                                      AddComment.create(context,
                                          path: widget.path);
                                    },
                                    leading: Icon(
                                      Icons.add,
                                      color: themeModel.textColor,
                                    ),
                                    title: Text(
                                      'Add Comment',
                                      style:
                                          themeModel.theme.textTheme.bodyText1,
                                    )),

                            ///Delivery boy comment
                            ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 20),
                                trailing: (widget.deliveryComment != null)
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: themeModel.textColor,
                                          size: 20,
                                        ),
                                        onPressed: () async {
                                          final bloc =
                                              Provider.of<OrderDetailsBloc>(
                                                  context,
                                                  listen: false);
                                          await bloc.removeDeliveryBoyComment();
                                        })
                                    : SizedBox(),
                                title: Text(
                                  'Delivery Boy Comment:',
                                  style: themeModel.theme.textTheme.bodyText2,
                                )),

                            ///Delivery boy image
                            (widget.deliveryComment != null)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                          ),
                                          child: Text(
                                            widget.deliveryComment!.comment,
                                            style: themeModel
                                                .theme.textTheme.bodyText1!
                                                .apply(
                                                    color: themeModel
                                                        .secondTextColor),
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          child: Text(
                                            "Delivery Boy Image:",
                                            style: themeModel
                                                .theme.textTheme.bodyText2,
                                          )),
                                      Align(
                                        alignment: Alignment.center,
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    child: Stack(
                                                      children: [
                                                        FadeInImage(
                                                          placeholder: MemoryImage(
                                                              kTransparentImage),
                                                          image: NetworkImage(
                                                              widget
                                                                  .deliveryComment!
                                                                  .image),
                                                        ),
                                                        Positioned(
                                                            right: 0,
                                                            top: 0,
                                                            child: IconButton(
                                                              icon: Icon(
                                                                Icons.clear,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            )),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: FadeInImage(
                                              placeholder: MemoryImage(
                                                  kTransparentImage),
                                              width: isPortrait
                                                  ? width * 0.5
                                                  : height * 0.5,
                                              image: NetworkImage(widget
                                                  .deliveryComment!.image),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: Text(
                                      'No comment provided by the delivery boy',
                                      style: themeModel
                                          .theme.textTheme.bodyText1!
                                          .apply(
                                              color:
                                                  themeModel.secondTextColor),
                                    )),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
              Container(
                height: 0.5,
                color: themeModel.secondTextColor,
              ),
            ],
          );
        },
      ),
    );
  }
}
