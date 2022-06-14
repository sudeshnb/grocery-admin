import 'package:flutter/material.dart';
import 'package:grocery_admin/models/data_models/date.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:provider/provider.dart';

class DateFilter extends StatefulWidget {
  final Date? date;

  static Future create(BuildContext context, {Date? date}) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return DateFilter._(
            date: date,
          );
        });
  }

  DateFilter._({this.date});

  @override
  _DateFilterState createState() => _DateFilterState();
}

class _DateFilterState extends State<DateFilter> {
  late List<Date> dates;

  String getValidDate(DateTime dateTime) {
    return dateTime.year.toString() +
        "-" +
        ((dateTime.month.toString().length == 1) ? "0" : "") +
        dateTime.month.toString() +
        "-" +
        ((dateTime.day.toString().length == 1) ? "0" : "") +
        dateTime.day.toString();
  }

  @override
  void initState() {
    super.initState();

    DateTime dateTime = DateTime.now();
    DateTime lastWeekDay = dateTime.subtract(Duration(days: 6));
    DateTime lastMonthDay = dateTime.subtract(Duration(days: 29));
    DateTime lastYearDay = dateTime.subtract(Duration(days: 364));

    dates = [
      Date(
          title: 'Today',
          firstDay: getValidDate(dateTime) + " 00:00",
          lastDay: getValidDate(dateTime) + " 23:59"),
      Date(
          title: 'Last 7 days',
          firstDay: getValidDate(lastWeekDay) + " 00:00",
          lastDay: getValidDate(dateTime) + " 23:59"),
      Date(
          title: 'Last 30 days',
          firstDay: getValidDate(lastMonthDay) + " 00:00",
          lastDay: getValidDate(dateTime) + " 23:59"),
      Date(
          title: 'Last Year',
          firstDay: getValidDate(lastYearDay) + " 00:00",
          lastDay: getValidDate(dateTime) + " 23:59"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          color: themeModel.secondBackgroundColor),
      child: Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: (widget.date == null)
                  ? themeModel.accentColor
                  : Colors.transparent,
            ),
            child: ListTile(
              title: (widget.date == null)
                  ? Text(
                      "All days",
                      style: themeModel.theme.textTheme.headline3!
                          .apply(color: Colors.white),
                    )
                  : Text(
                    "All days",
                    style: themeModel.theme.textTheme.bodyText1,
                    ),

              onTap: () {
                Navigator.pop(context, "ALL");
              },
            ),
          ),
          Column(
            children: List.generate(dates.length, (position) {
              return Container(
                color: (dates[position] == widget.date)
                    ? themeModel.accentColor
                    : Colors.transparent,
                child: ListTile(
                  title: (dates[position] == widget.date)
                      ? Text(
                    dates[position].title,
                    style: themeModel.theme.textTheme.headline3!
                        .apply(color: Colors.white),
                  )
                      : Text(
                    dates[position].title,
                    style: themeModel.theme.textTheme.bodyText1,
                  ),
                  onTap: () {
                    Navigator.pop(context, dates[position]);
                  },
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}
