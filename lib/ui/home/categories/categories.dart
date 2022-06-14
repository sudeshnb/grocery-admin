import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_admin/blocs/categories_bloc.dart';
import 'package:grocery_admin/models/data_models/category.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/services/database.dart';
import 'package:grocery_admin/ui/home/categories/add_category.dart';
import 'package:grocery_admin/widgets/cards/category_card.dart';
import 'package:grocery_admin/widgets/fade_in.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class Categories extends StatefulWidget {
  final CategoriesBloc bloc;

  Categories._({required this.bloc});

  static  create(BuildContext context) {
    final database = Provider.of<Database>(context, listen: false);

    Navigator.push(context, CupertinoPageRoute(builder: (context){

      return Provider<CategoriesBloc>(
        create: (context) => CategoriesBloc(database: database),
        child: Consumer<CategoriesBloc>(
          builder: (context, bloc, _) {
            return Categories._(
              bloc: bloc,
            );
          },
        ),
      );

    }));
  }

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories>{





  late Stream<List<Category>> _categoriesStream;
  @override
  void initState() {
    super.initState();

    _categoriesStream=widget.bloc.getCategories();

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
            'Categories',
          style: themeModel.theme.textTheme.headline3,
        ),
        centerTitle: true,
        backgroundColor: themeModel.secondBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: themeModel.textColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),
      body: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 80),
        children: [
          GestureDetector(
            onTap: () {
              AddCategory.create(context);
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
                    child:
                        Text(
                            "Add Category",
                          style: themeModel.theme.textTheme.headline3!.apply(
                            color: themeModel.accentColor
                          ),
                        )
                  )
                ],
              ),
            ),
          ),
          StreamBuilder<List<Category>>(
              stream: _categoriesStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Category> categories = snapshot.data!;


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
                          child: CategoryCard(
                              category: categories[position], function: () async {
                            await widget.bloc.removeCategory(categories[position].title);
                            Navigator.pop(context);
                          }));
                    },
                    itemCount: categories.length,

                  );
                } else if (snapshot.hasError) {
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
    );
  }

}
