import 'package:dish_dispatch_restaurant_frontend/providers/api_provider.dart';
import 'package:dish_dispatch_restaurant_frontend/widgets/orders/list_tile.dart';
import 'package:flutter/material.dart';
import 'package:dish_dispatch_restaurant_frontend/models/orders.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  late Timer refresher;
  late APIProvider api;
  late Future<List<BaseOrderInOrder>> ordersFuture;

  @override
  void initState() {
    api = Provider.of<APIProvider>(context, listen: false);
    ordersFuture = api.getRestaurantOrders();
    refresher = Timer.periodic(const Duration(seconds: 10), (t) {
      setState(() {
        ordersFuture = api.getRestaurantOrders();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    refresher.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Orders"),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final orders = snapshot.requireData;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Orders"),
          ),
          body: ListView.builder(
            itemBuilder: (context, i) {
              return OrderListTile(order: orders[i]);
            },
            itemCount: orders.length,
          ),
        );
      },
    );
  }
}
