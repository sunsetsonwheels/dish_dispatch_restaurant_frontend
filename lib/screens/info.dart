import 'package:dish_dispatch_restaurant_frontend/models/restaurant.dart';
import 'package:dish_dispatch_restaurant_frontend/providers/api_provider.dart';
import 'package:dish_dispatch_restaurant_frontend/widgets/utils/error_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final cuisineController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    cuisineController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    APIProvider api = Provider.of<APIProvider>(context, listen: false);
    Restaurant newRestaurant = api.restaurant!.clone();
    newRestaurant.name = nameController.text;
    newRestaurant.cuisine = cuisineController.text;
    newRestaurant.phone = phoneController.text;
    newRestaurant.address = addressController.text;
    try {
      await api.editRestaurant(newRestaurant);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Saved!")));
    } catch (error) {
      showDialog(
        context: context,
        builder: (_) => ErrorAlertWidget(
          error: error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Info"),
        actions: [
          IconButton(
            onPressed: () async {
              await Provider.of<APIProvider>(context, listen: false).logout();
              Routemaster.of(context).replace("/login");
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<APIProvider>(
        builder: (context, api, child) {
          final restaurant = api.restaurant!;
          nameController.text = restaurant.name;
          cuisineController.text = restaurant.cuisine;
          phoneController.text = restaurant.phone;
          addressController.text = restaurant.address;
          List<Widget> listChildren = [
            ListTile(
              title: const Text("Name"),
              subtitle: TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Name cannot be empty!";
                  }
                  return null;
                },
              ),
              leading: const Icon(Icons.table_restaurant),
            ),
            ListTile(
              title: const Text("Cuisine"),
              subtitle: TextFormField(
                controller: cuisineController,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Cuisine cannot be empty!";
                  }
                  return null;
                },
              ),
              leading: const Icon(Icons.restaurant_menu),
            ),
            ListTile(
              title: const Text("Phone"),
              subtitle: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Phone cannot be empty!";
                  }
                  return null;
                },
              ),
              leading: const Icon(Icons.phone),
            ),
            ListTile(
              title: const Text("Address"),
              subtitle: TextFormField(
                controller: addressController,
                keyboardType: TextInputType.streetAddress,
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return "Address cannot be empty!";
                  }
                  return null;
                },
              ),
              leading: const Icon(Icons.navigation),
            ),
          ];
          return Form(
            key: formKey,
            child: ListView(
              children: listChildren,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: save,
        child: const Icon(Icons.save),
      ),
    );
  }
}
