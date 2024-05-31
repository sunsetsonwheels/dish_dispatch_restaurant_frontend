import 'package:cached_network_image/cached_network_image.dart';
import 'package:dish_dispatch_restaurant_frontend/models/restaurant.dart';
import 'package:dish_dispatch_restaurant_frontend/providers/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class MenuGridItem extends StatelessWidget {
  final String name;
  final MenuItem item;

  const MenuGridItem({
    super.key,
    required this.name,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    APIProvider api = Provider.of<APIProvider>(context, listen: false);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Routemaster.of(context).push("/menu/$name");
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: colorScheme.secondaryContainer,
            title: Text(
              name,
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              "\$${item.price.toStringAsFixed(2)}",
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
          ),
          child: CachedNetworkImage(
            imageUrl: api.getRestaurantImageUri(
              restaurant: api.restaurant!.phone,
              filename: "$name.jpg",
            ),
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
              return ErrorWidget(error);
            },
          ),
        ),
      ),
    );
  }
}
