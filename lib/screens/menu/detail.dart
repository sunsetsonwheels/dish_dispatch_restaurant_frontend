import 'package:dish_dispatch_restaurant_frontend/models/restaurant.dart';
import 'package:dish_dispatch_restaurant_frontend/providers/api_provider.dart';
import 'package:dish_dispatch_restaurant_frontend/widgets/utils/error_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';

class MenuItemDetailScreen extends StatefulWidget {
  final bool isNew;
  final String? name;
  final MenuItem? item;

  const MenuItemDetailScreen({
    super.key,
    this.isNew = false,
    this.name,
    this.item,
  });

  @override
  State<MenuItemDetailScreen> createState() => _MenuItemDetailScreenState();
}

class _MenuItemDetailScreenState extends State<MenuItemDetailScreen> {
  final formKey = GlobalKey<FormState>();
  final imagePicker = ImagePicker();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  XFile? image;
  bool isSaving = false;

  @override
  void initState() {
    if (!widget.isNew) {
      nameController.text = widget.name!;
      descriptionController.text = widget.item!.description;
      priceController.text = widget.item!.price.toStringAsFixed(2);
    }
    super.initState();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isSaving = true;
    });
    try {
      final api = Provider.of<APIProvider>(context, listen: false);
      Restaurant newRestaurant = api.restaurant!.clone();
      newRestaurant.menu[nameController.text] = MenuItem(
        description: descriptionController.text,
        price: double.parse(priceController.text),
      );
      await api.editRestaurant(newRestaurant);
      if (image != null) {
        await api.putNewImage(name: nameController.text, file: image!);
      }
      Routemaster.of(context).pop();
    } catch (error) {
      showDialog(
        context: context,
        builder: (_) => ErrorAlertWidget(error: error),
      );
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<void> delete() async {
    setState(() {
      isSaving = true;
    });
    try {
      final api = Provider.of<APIProvider>(context, listen: false);
      Restaurant newRestaurant = api.restaurant!.clone();
      newRestaurant.menu.remove(widget.name);
      await api.editRestaurant(newRestaurant);
      Routemaster.of(context).pop();
    } catch (error) {
      showDialog(
        context: context,
        builder: (_) => ErrorAlertWidget(error: error),
      );
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listChildren = [
      ListTile(
        title: const Text("Name"),
        subtitle: TextFormField(
          controller: nameController,
          readOnly: isSaving,
          validator: (value) {
            if (value != null && value.isEmpty) {
              return "Name cannot be empty!";
            }
            return null;
          },
        ),
      ),
      ListTile(
        title: const Text("Description"),
        subtitle: TextFormField(
          controller: descriptionController,
          maxLines: 2,
          readOnly: isSaving,
          validator: (value) {
            if (value != null && value.isEmpty) {
              return "Description cannot be empty!";
            }
            return null;
          },
        ),
      ),
      ListTile(
        title: const Text("Price"),
        subtitle: TextFormField(
          controller: priceController,
          readOnly: isSaving,
          decoration: const InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(right: 4),
              child: Text("\$"),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
          ],
          validator: (value) {
            if (value != null && value.isEmpty) {
              if (value.isEmpty) {
                return "Price cannot be empty!";
              } else if (double.tryParse(value) == null) {
                return "Price is not a valid double number!";
              }
            }
            return null;
          },
        ),
      ),
      ListTile(
        title: const Text("New image"),
        subtitle: Text(image != null ? image!.name : "Not selected"),
        trailing: const Icon(Icons.add_a_photo),
        onTap: !isSaving
            ? () async {
                final newImage = await imagePicker.pickImage(
                  source: ImageSource.gallery,
                  requestFullMetadata: false,
                );
                setState(() {
                  image = newImage;
                });
              }
            : null,
        onLongPress: !isSaving
            ? () {
                setState(() {
                  image = null;
                });
              }
            : null,
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? "New item" : "Edit item"),
        actions: [
          if (!widget.isNew)
            IconButton(
              onPressed: delete,
              icon: const Icon(Icons.delete_forever),
            ),
        ],
        automaticallyImplyLeading: !isSaving,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: listChildren,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: !isSaving ? save : null,
        child: Icon(widget.isNew ? Icons.add : Icons.save),
      ),
    );
  }
}
