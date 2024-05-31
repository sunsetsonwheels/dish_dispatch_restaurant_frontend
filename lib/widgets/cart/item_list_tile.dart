import 'package:cached_network_image/cached_network_image.dart';
import 'package:dish_dispatch_restaurant_frontend/models/cart.dart';
import 'package:dish_dispatch_restaurant_frontend/models/restaurant.dart';
import 'package:dish_dispatch_restaurant_frontend/providers/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItemListTile extends StatelessWidget {
  final BaseRestaurant restaurant;
  final String item;
  final CartItem details;
  final bool readOnly;

  const CartItemListTile({
    super.key,
    required this.restaurant,
    required this.item,
    required this.details,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    String subtotal = (details.quantity * details.price).toStringAsFixed(2);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          Provider.of<APIProvider>(context, listen: false)
              .getRestaurantImageUri(
            restaurant: restaurant.phone,
            filename: "$item.jpg",
          ),
        ),
      ),
      title: Text(
        item,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text("x${details.quantity}, \$$subtotal"),
    );
  }
}
