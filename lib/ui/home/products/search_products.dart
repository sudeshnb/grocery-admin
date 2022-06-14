import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_admin/blocs/search_products_bloc.dart';
import 'package:grocery_admin/models/data_models/product.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/widgets/cards/product_card.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class SearchProducts extends StatefulWidget {
  final SearchProductsBloc bloc;

  SearchProducts._({required this.bloc});

  static  Future<bool?> create(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    return Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return Provider<SearchProductsBloc>(
        create: (context) => SearchProductsBloc(database: database),
        child: Consumer<SearchProductsBloc>(
          builder: (context, bloc, _) {
            return SearchProducts._(bloc: bloc);
          },
        ),
      );
    }));
  }

  @override
  _SearchProductsState createState() => _SearchProductsState();
}

class _SearchProductsState extends State<SearchProducts> {
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return WillPopScope(
        onWillPop: (){
          return widget.bloc.onWillPop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                'Search',
              style: themeModel.theme.textTheme.headline3,
            ),

            backgroundColor: themeModel.secondBackgroundColor,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: themeModel.textColor,
              ),
              onPressed: () {
                widget.bloc.onWillPop(context);
              },
            ),
          ),
          body: NotificationListener(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollEndNotification) {
                if (_scrollController.position.extentAfter == 0) {
                  if (searchController.text.isNotEmpty) {
                    widget.bloc.loadProducts(searchController.text, (width ~/ 180) * (height ~/180));
                  }
                }
              }
              return false;
            },
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      color: themeModel.secondBackgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 2,
                            offset: Offset(0, 5),
                            color: themeModel.shadowColor)
                      ]),
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (value) {
                      if (searchController.text.isNotEmpty) {
                        widget.bloc.clearHistory();
                        widget.bloc.loadProducts(searchController.text, (width ~/ 180) * (height ~/180));
                      }

                      setState(() {});
                    },
                    onChanged: (value) {
                      if (searchController.text.length == 1) {
                        if (searchController.text[0] !=
                            searchController.text[0].toUpperCase()) {
                          searchController.text = searchController.text
                              .replaceFirst(searchController.text[0],
                              searchController.text[0].toUpperCase());
                          searchController.selection = TextSelection.fromPosition(
                              TextPosition(offset: searchController.text.length));
                        }
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      hintText: "Search...",
                    ),
                  ),
                ),
                (searchController.text.isNotEmpty)
                    ? StreamBuilder<List<Product>>(
                  stream: widget.bloc.productsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Product> products = snapshot.data!;

                      if (products.length == 0) {
                        ///If nothing found
                        return Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: FadeIn(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'images/nothing_found.svg',
                                    width: isPortrait
                                        ? width * 0.5
                                        : height * 0.5,
                                    fit: BoxFit.cover,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child:  Text(
                                      'Nothing found!',
                                      style: themeModel.theme.textTheme.headline3!.apply(
                                        color:  themeModel.accentColor
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ]),
                          ),
                        );
                      } else {
                        ///If there are products
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: width ~/ 180,
                          ),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                              left: 16, right: 16, bottom: 80),
                          itemBuilder: (context,position){
                            return FadeIn(
                              child: ProductCard(
                                  product: products[position],
                                  edit: widget.bloc.editProductLocally,
                                  delete: () async {
                                    await widget.bloc
                                        .removeProduct(products[position].reference);
                                    Navigator.pop(context);
                                    widget.bloc.removeProductLocally(products[position]);


                                  }),
                            );
                          },
                          itemCount: snapshot.data!.length,

                        );
                      }
                    } else if (snapshot.hasError) {
                      ///If there is an error
                      return FadeIn(
                        child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: SvgPicture.asset(
                                'images/error.svg',
                                width: width * 0.5,
                                fit: BoxFit.cover,
                              ),
                            )),
                      );
                    } else {
                      ///If Loading
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                )
                    : SizedBox(),
              ],
            ),
          ),
        ),);
  }
}
