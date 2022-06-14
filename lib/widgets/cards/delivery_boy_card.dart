import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grocery_admin/blocs/delivery_boys_bloc.dart';
import 'package:grocery_admin/models/data_models/delivery_boy.dart';
import 'package:grocery_admin/models/state_models/theme_model.dart';
import 'package:grocery_admin/ui/home/delivery_boys/add_delivery_boy.dart';
import 'package:grocery_admin/widgets/transparent_image.dart';
import 'package:provider/provider.dart';

class DeliveryBoyCard extends StatelessWidget {
  final DeliveryBoy deliveryBoy;
  final bool selectAction;
  const DeliveryBoyCard(
      {Key? key, required this.deliveryBoy, this.selectAction = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);
    final bloc = Provider.of<DeliveryBoysBloc>(context);

    return Slidable(
      child: ListTile(
        title: Text(
          deliveryBoy.fullName,
          style: themeModel.theme.textTheme.headline3,
        ),
        subtitle: Text(
          "Email: " + deliveryBoy.email,
          style: themeModel.theme.textTheme.bodyText1!
              .apply(color: themeModel.secondTextColor),
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            image: (deliveryBoy.image != null)
                ? NetworkImage(deliveryBoy.image!)
                : AssetImage('images/profile.png') as ImageProvider,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        onTap: () {
          if (selectAction) {
            Navigator.pop(context, deliveryBoy);
          } else {
            AddDeliveryBoy.create(context, deliveryBoy: deliveryBoy);
          }
        },
      ),
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        IconSlideAction(
          caption: 'Edit',
          color: themeModel.accentColor,
          icon: Icons.edit,
          foregroundColor: themeModel.textColor,
          onTap: () {
            AddDeliveryBoy.create(context, deliveryBoy: deliveryBoy);
          },
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () async {
            await bloc.removeDelivery(deliveryBoy.email);
          },
        ),
      ],
    );
  }
}
