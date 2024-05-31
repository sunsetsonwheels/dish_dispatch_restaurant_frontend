import 'package:dish_dispatch_restaurant_frontend/models/orders.dart';
import 'package:dish_dispatch_restaurant_frontend/widgets/orders/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';

class OrderListTile extends StatelessWidget {
  final BaseOrderInOrder order;
  final DateFormat fmt = DateFormat("dd/MM/yyyy hh:mm");

  OrderListTile({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(fmt.format(order.date)),
      subtitle: Text("\$${order.total.toStringAsFixed(2)}"),
      trailing: OrderStatusChip(
        status: order.status,
      ),
      onTap: () {
        Routemaster.of(context).push("/orders/${order.id}");
      },
    );
  }
}
