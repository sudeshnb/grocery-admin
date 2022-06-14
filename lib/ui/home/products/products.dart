import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_admin/blocs/products_bloc.dart';
import 'package:grocery_admin/models/data_models/product.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/home/products/add_product.dart';
import 'package:grocery_admin/ui/home/products/search_products.dart';
import 'package:grocery_admin/widgets/cards/product_card.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class Products extends StatefulWidget {
  final ProductsBloc bloc;

  Products({required this.bloc});

  static Widget create(BuildContext context) {
    final database = Provider.of<Database>(context,listen: false);

    return Provider<ProductsBloc>(
        create: (context) => ProductsBloc(database: database),
      child:Consumer<ProductsBloc>(
      builder: (context, bloc, _) {
        return Products(
          bloc: bloc,
        );
      },
    ));
  }

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products>{


  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    widget.bloc.loadProducts(15);
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;


    return Scaffold(
      appBar: AppBar(
        shadowColor: themeModel.shadowColor,
        title: Text(
          'Products',
          style: themeModel.theme.textTheme.headline3,
        ),

        centerTitle: true,
        backgroundColor: themeModel.secondBackgroundColor,
        leading: Container(),
        actions: [
          IconButton(
              icon: Icon(
                Icons.search,
                color: themeModel.textColor,
              ),
              onPressed: () {
                SearchProducts.create(context).then((value){
                  if(value!=null){

                    widget.bloc.refresh((width ~/ 180) * (height ~/180));

                  }

                });
              })
        ],
      ),
      body: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollEndNotification) {
            if (_scrollController.position.extentAfter == 0) {
              widget.bloc.loadProducts((width ~/ 180) * (height ~/180));

            }
          }
          return false;
        },

        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 80),
          children: [
            GestureDetector(
              onTap: () {
                AddProduct.create(context).then((value){
                  if(value!=null){

                    widget.bloc.addProductLocally(value);

                  }


                });
              },
              child: Container(
                margin: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: themeModel.secondBackgroundColor,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 2,
                          offset: Offset(0, 5),
                          color: themeModel.shadowColor)
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: themeModel.accentColor,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child:Text(
                          "Add Product",
                        style: themeModel.theme.textTheme.headline3!.apply(
                          color: themeModel.accentColor
                        ),
                      )
                    )
                  ],
                ),
              ),
            ),



            StreamBuilder<List<Product>>(
                stream: widget.bloc.productsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Product> products = snapshot.data!;



                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (width ~/ 180),
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(left: 16, right: 16, top: 20),

                      itemBuilder: (context,position){
                        return FadeIn(
                            duration: Duration(milliseconds: 300),
                            child: ProductCard(
                                edit: widget.bloc.editProductLocally,
                                product: products[position],
                                delete: () async {
                                  await widget.bloc.removeProduct(products[position].reference);
                                  Navigator.pop(context);
                                  widget.bloc.removeProductLocally(products[position]);

                                }));
                      },
                      itemCount: products.length,
                    );
                  } else if (snapshot.hasError) {
                    print(snapshot.error);

                    print(snapshot.stackTrace);
                    return Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: SvgPicture.asset(
                          'images/error.svg',
                          width: isPortrait ? width * 0.5 : height * 0.5,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }


}
