import 'package:flutter/material.dart';
import 'package:grocery_admin/models/data_models/product.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/ui/home/products/add_product.dart';
import 'package:grocery_admin/widgets/buttons/default_button.dart';
import 'package:grocery_admin/widgets/transparent_image.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final void Function() delete;
  final void Function(Product) edit;
  const ProductCard({Key? key,
    required this.product,
    required this.delete,
    required this.edit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
  //  double width = MediaQuery.of(context).size.width;

    return GestureDetector(
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
        child: Stack(
          children: [
            Padding(
              padding:EdgeInsets.all(5),

              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FadeInImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(product.image),
                        placeholder: MemoryImage(kTransparentImage),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: Text(
                          product.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: themeModel.theme.textTheme.bodyText1,
                        )


                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        child: Text(
                          "${(product.pricePerKg == null) ? product.pricePerPiece : product.pricePerKg}\$",
                          style: themeModel.theme.textTheme.bodyText1!.apply(
                            color: themeModel.priceColor,
                          ),
                        ),

                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: themeModel.secondTextColor,
                ),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              color: themeModel.theme.backgroundColor),
                          padding: EdgeInsets.all(20),
                          child: Wrap(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                    "Are you Sure?",
                                  style: themeModel.theme.textTheme.headline2,
                                )
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      DefaultButton(
                                        widget: Text(
                                  "Cancel",
                                    style: themeModel.theme.textTheme.headline3!.apply(
                                      color: themeModel.secondTextColor
                                    ),
                                  ),


                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        color: themeModel.secondTextColor,
                                        border: true,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: DefaultButton(
                                            widget: Text(
                                                "Delete",
                                              style: themeModel.theme.textTheme.headline3!.apply(
                                                color: Colors.white
                                              ),
                                            ),

                                            onPressed: delete,
                                            color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        AddProduct.create(context, product: product).then((value) {
          if (value != null) {
            edit(value);
          }
        });
      },
    );
  }
}
