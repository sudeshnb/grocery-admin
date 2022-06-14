import 'package:flutter/material.dart';
import 'package:grocery_admin/blocs/orders_reader_bloc.dart';
import 'package:grocery_admin/models/data_models/date.dart';
import 'package:provider/provider.dart';

class OrdersModel with ChangeNotifier {
  Date? date;

  void changeDateRange(BuildContext context, String status, [Date? date]) {
    this.date = date;

    final bloc = Provider.of<OrdersReaderBloc>(context, listen: false);
    bloc.refresh(10, status, date);
  }
}
