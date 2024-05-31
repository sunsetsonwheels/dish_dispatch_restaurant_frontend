import 'dart:async';

import 'package:dish_dispatch_restaurant_frontend/models/orders.dart';
import 'package:dish_dispatch_restaurant_frontend/models/restaurant.dart';
import 'package:dish_dispatch_restaurant_frontend/providers/api_provider.dart';
import 'package:dish_dispatch_restaurant_frontend/widgets/cart/item_list_tile.dart';
import 'package:dish_dispatch_restaurant_frontend/widgets/orders/status_chip.dart';
import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String id;

  const OrderDetailsScreen({super.key, required this.id});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late APIProvider api;
  late Future<OrderInOrder> orderFuture;

  @override
  void initState() {
    api = Provider.of<APIProvider>(context, listen: false);
    orderFuture = api.getRestaurantOrder(id: widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: orderFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final order = snapshot.requireData;
        TextStyle? titleMedium = Theme.of(context).textTheme.titleMedium;
        List<DropdownMenuEntry<OrderStatus>> statuses = [];
        for (final status in OrderStatus.values) {
          statuses.add(DropdownMenuEntry(value: status, label: status.name));
        }
        List<Widget> listChildren = [
          if (order.review != null)
            ListTile(
              title: const Text("Review"),
              subtitle: Text(order.review!.comment),
              trailing: AnimatedRatingStars(
                initialRating: order.review!.rating,
                onChanged: (_) {},
                customFilledIcon: Icons.star,
                customHalfFilledIcon: Icons.star_half,
                customEmptyIcon: Icons.star_outline,
              ),
            ),
          if (order.review != null) const Divider(),
          ListTile(
            leading: Text(
              "Order status",
              style: titleMedium,
            ),
            trailing: DropdownMenu<OrderStatus>(
              initialSelection: order.status,
              onSelected: (value) {
                if (value != null) {
                  api.setRestaurantOrderStatus(id: widget.id, status: value);
                }
              },
              dropdownMenuEntries: statuses,
            ),
          ),
          ListTile(
            leading: Text(
              "Delivery contact",
              style: titleMedium,
            ),
          ),
          ListTile(
            title: const Text("Phone"),
            subtitle: Text(order.parent!.deliveryInfo.phone),
            trailing: const Icon(Icons.phone),
          ),
          ListTile(
            title: const Text("Name"),
            subtitle: Text(order.parent!.deliveryInfo.name),
            trailing: const Icon(Icons.person),
          ),
          ListTile(
            title: const Text("Address"),
            subtitle: Text(order.parent!.deliveryInfo.address),
            trailing: const Icon(Icons.location_pin),
          ),
          ListTile(
            leading: Text(
              "Ordered items",
              style: titleMedium,
            ),
          ),
        ];
        for (final orderItemEntry in order.items.entries) {
          listChildren.add(
            CartItemListTile(
              restaurant: api.restaurant!,
              item: orderItemEntry.key,
              details: orderItemEntry.value,
              readOnly: true,
            ),
          );
        }
        listChildren.addAll([
          ListTile(
            leading: Text(
              "Total",
              style: titleMedium,
            ),
            trailing: Text(
              "\$${order.total.toStringAsFixed(2)}",
              style: titleMedium,
            ),
          ),
        ]);
        return Scaffold(
          appBar: AppBar(
            title: const Text("Order details"),
          ),
          body: ListView(
            children: listChildren,
          ),
        );
      },
    );
  }
}
