import 'package:dish_dispatch_restaurant_frontend/models/restaurant.dart';
import 'package:dish_dispatch_restaurant_frontend/providers/api_provider.dart';
import 'package:dish_dispatch_restaurant_frontend/root_navigation.dart';
import 'package:dish_dispatch_restaurant_frontend/screens/info.dart';
import 'package:dish_dispatch_restaurant_frontend/screens/login.dart';
import 'package:dish_dispatch_restaurant_frontend/screens/menu/detail.dart';
import 'package:dish_dispatch_restaurant_frontend/screens/menu/grid.dart';
import 'package:dish_dispatch_restaurant_frontend/screens/orders/details.dart';
import 'package:dish_dispatch_restaurant_frontend/screens/orders/list.dart';
import 'package:dish_dispatch_restaurant_frontend/screens/stats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => APIProvider(),
    child: const RestaurantFrontendApp(),
  ));
}

class RestaurantFrontendApp extends StatefulWidget {
  const RestaurantFrontendApp({super.key});

  @override
  State<RestaurantFrontendApp> createState() => RestaurantFrontendAppState();
}

class RestaurantFrontendAppState extends State<RestaurantFrontendApp> {
  final routeInformationParser = const RoutemasterParser();
  final routerDelegate = RoutemasterDelegate(
    routesBuilder: (context) {
      APIProvider api = Provider.of<APIProvider>(context, listen: false);

      return RouteMap(
        routes: {
          '/': (route) => api.isLoggedIn
              ? const TabPage(
                  child: RootNavigation(),
                  paths: ["/orders", "/menu", "/stats", "/info"],
                )
              : const Redirect("/login"),
          "/orders": (route) {
            if (!api.isLoggedIn) {
              return const Redirect("/login");
            }
            return const MaterialPage(child: OrdersListScreen());
          },
          '/orders/:id': (route) {
            if (!api.isLoggedIn) {
              return const Redirect("/login");
            }
            String? id = route.pathParameters['id'];
            if (id == null) {
              return const Redirect('/orders');
            }
            return MaterialPage(
              child: OrderDetailsScreen(
                id: id,
              ),
            );
          },
          "/menu": (route) {
            if (!api.isLoggedIn) {
              return const Redirect("/login");
            }
            return const MaterialPage(child: MenuGridScreen());
          },
          "/menu/:name": (route) {
            if (!api.isLoggedIn) {
              return const Redirect("/login");
            }
            String? name = route.pathParameters['name'];
            if (name == null) {
              return const Redirect("/menu");
            }
            name = Uri.decodeFull(name);
            MenuItem? item = api.restaurant?.menu[name];
            return MaterialPage(
              child: MenuItemDetailScreen(
                name: name,
                item: item,
              ),
            );
          },
          "/new/menu_item": (route) {
            if (!api.isLoggedIn) {
              return const Redirect("/login");
            }
            return const MaterialPage(
              child: MenuItemDetailScreen(isNew: true),
            );
          },
          '/stats': (route) {
            if (!api.isLoggedIn) {
              return const Redirect("/login");
            }
            return const MaterialPage(child: StatsScreen());
          },
          '/info': (route) {
            if (!api.isLoggedIn) {
              return const Redirect("/login");
            }
            return const MaterialPage(child: InfoScreen());
          },
          '/login': (route) => const MaterialPage(child: LoginScreen()),
        },
      );
    },
  );
  final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorSchemeSeed: Colors.green.shade800,
    useMaterial3: true,
  );
  final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.green.shade800,
    useMaterial3: true,
  );

  late Future<void> providerInit;

  @override
  void initState() {
    super.initState();
    providerInit = Provider.of<APIProvider>(context, listen: false).init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: providerInit,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            title: "Loading...",
            theme: lightTheme,
            darkTheme: darkTheme,
            builder: (context, child) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        }
        return MaterialApp.router(
          title: "Dish Dispatch",
          theme: lightTheme,
          darkTheme: darkTheme,
          routeInformationParser: routeInformationParser,
          routerDelegate: routerDelegate,
        );
      },
    );
  }
}
