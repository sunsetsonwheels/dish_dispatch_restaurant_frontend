import 'package:json_annotation/json_annotation.dart';
import 'package:dish_dispatch_restaurant_frontend/models/orders.dart';

part 'restaurant.g.dart';

@JsonSerializable()
class BaseRestaurant {
  String phone;
  String name;
  String cuisine;

  BaseRestaurant({
    required this.phone,
    required this.name,
    required this.cuisine,
  });

  factory BaseRestaurant.fromJson(Map<String, dynamic> json) =>
      _$BaseRestaurantFromJson(json);

  factory BaseRestaurant.fromOrderRestaurant(OrderRestaurant restaurant) =>
      BaseRestaurant(
        phone: restaurant.phone,
        name: restaurant.name,
        cuisine: "",
      );
}

@JsonSerializable()
class RestaurantResponse {
  final List<BaseRestaurant> restaurants;
  final List<String> cuisines;

  RestaurantResponse({
    required this.restaurants,
    required this.cuisines,
  });

  factory RestaurantResponse.fromJson(Map<String, dynamic> json) =>
      _$RestaurantResponseFromJson(json);
}

@JsonSerializable()
class MenuItem {
  String description;
  double price;

  MenuItem({
    required this.description,
    required this.price,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}

@JsonSerializable()
class Restaurant extends BaseRestaurant {
  String address;
  Map<String, MenuItem> menu;

  Restaurant({
    required super.phone,
    required super.name,
    required super.cuisine,
    required this.address,
    required this.menu,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantToJson(this);

  Restaurant clone() => Restaurant(
      phone: phone, name: name, cuisine: cuisine, address: address, menu: menu);
}

@JsonSerializable(createToJson: false)
class RestaurantRating {
  final double average;
  final List<String> recent;

  const RestaurantRating({required this.average, required this.recent});

  factory RestaurantRating.fromJson(Map<String, dynamic> json) =>
      _$RestaurantRatingFromJson(json);
}

@JsonSerializable(createToJson: false)
class RestaurantRevenue {
  final double total;

  const RestaurantRevenue({required this.total});

  factory RestaurantRevenue.fromJson(Map<String, dynamic> json) =>
      _$RestaurantRevenueFromJson(json);
}
