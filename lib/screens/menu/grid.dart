import 'package:dish_dispatch_restaurant_frontend/providers/api_provider.dart';
import 'package:dish_dispatch_restaurant_frontend/widgets/menu/grid_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';

class MenuGridScreen extends StatelessWidget {
  const MenuGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        actions: [
          IconButton(
            onPressed: () async {
              await Provider.of<APIProvider>(context, listen: false)
                  .getRestaurant();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<APIProvider>(
        builder: (context, value, child) {
          List<Widget> gridChildren = [];
          for (final name in value.restaurant!.menu.keys) {
            gridChildren.add(
              MenuGridItem(
                name: name,
                item: value.restaurant!.menu[name]!,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: gridChildren,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Routemaster.of(context).push("/new/menu_item");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
