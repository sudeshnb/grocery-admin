import 'package:flutter/material.dart';
import 'package:grocery_admin/models/data_models/category.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/ui/home/categories/add_category.dart';
import 'package:grocery_admin/widgets/buttons/default_button.dart';
import 'package:grocery_admin/widgets/transparent_image.dart';
import 'package:provider/provider.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final void Function() function;

  const CategoryCard({Key? key, required this.category, required this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

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
              padding: EdgeInsets.all(5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FadeInImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(category.image),
                        placeholder: MemoryImage(kTransparentImage),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: Text(category.title,
                            style: themeModel.theme.textTheme.bodyText1,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1)),
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
                                ),
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
                                          style: themeModel
                                              .theme.textTheme.headline3!
                                              .apply(
                                                  color: themeModel
                                                      .secondTextColor),
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
                                              style: themeModel
                                                  .theme.textTheme.headline3!
                                                  .apply(color: Colors.white),
                                            ),
                                            onPressed: function,
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
        AddCategory.create(context, category: category);
      },
    );
  }
}
