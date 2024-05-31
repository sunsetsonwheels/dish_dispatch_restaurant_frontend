import 'dart:convert';

import 'package:dish_dispatch_restaurant_frontend/models/customers.dart';
import 'package:dish_dispatch_restaurant_frontend/models/orders.dart';
import 'package:dish_dispatch_restaurant_frontend/models/restaurant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class HttpBodyType {
  static const String json = "application/json; charset=utf-8";
  static const String multipartForm = "multipart/form-data";
  static const String plainText = "text/plain; charset=utf-8";
}

class APIRequestError implements Exception {
  int? code;
  String? detail;

  APIRequestError(this.code, this.detail);

  @override
  String toString() {
    return "ApiRequestError: $detail ($code)";
  }
}

class APIProvider extends ChangeNotifier {
  late final SharedPreferences _prefs;
  final _secureStorage = const FlutterSecureStorage();
  final http.Client _client = http.Client();

  String _apiRoot = "10.0.2.2:8000";

  CustomerAuth? _customerAuth;
  Restaurant? restaurant;
  bool get isLoggedIn => restaurant != null;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _apiRoot = _prefs.getString("apiRoot") ?? "localhost:8000";
    final customerPhone = await _secureStorage.read(key: "phone");
    final customerPassword = await _secureStorage.read(key: "password");
    if (customerPhone != null && customerPassword != null) {
      _customerAuth = CustomerAuth(
        phone: customerPhone,
        password: customerPassword,
      );
    }
    await getRestaurant();
  }

  Future<void> saveCustomerAuth({
    required String phone,
    required String password,
  }) async {
    await _secureStorage.write(key: "phone", value: phone);
    await _secureStorage.write(key: "password", value: password);
    _customerAuth = CustomerAuth(phone: phone, password: password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'phone');
    await _secureStorage.delete(key: 'password');
    _customerAuth = null;
    notifyListeners();
  }

  // MARK: Core

  Future<String> _sendRequest(
    String endpoint, {
    Map<String, String> queryParams = const {},
    String method = "GET",
    dynamic body,
    XFile? file,
    String? contentType = HttpBodyType.json,
    bool authRequired = false,
  }) async {
    Uri fullUri = Uri.http(_apiRoot, endpoint, queryParams);
    late http.BaseRequest request;
    if (contentType == HttpBodyType.multipartForm) {
      http.MultipartRequest req = http.MultipartRequest(method, fullUri);
      for (final kv in (body as Map<String, String>).entries) {
        req.fields[kv.key] = kv.value;
      }
      if (file != null) {
        req.files.add(
          http.MultipartFile(
            "file",
            file.openRead(),
            await file.length(),
            filename: "image.jpg",
            contentType: MediaType("image", "jpeg"),
          ),
        );
      }
      request = req;
    } else {
      http.Request req = http.Request(method, fullUri);
      if (body != null) {
        switch (contentType) {
          case HttpBodyType.json:
            req.body = jsonEncode(body);
            break;
          case HttpBodyType.plainText:
            req.body = body as String;
        }
      }
      request = req;
    }
    if (contentType != null) {
      request.headers['Content-Type'] = contentType;
    }
    if (authRequired) {
      request.headers['Authorization'] = _customerAuth.toString();
    }
    http.Response response =
        await http.Response.fromStream(await _client.send(request));
    if (response.statusCode >= 299) {
      throw APIRequestError(response.statusCode, response.body);
    }
    return response.body;
  }

  Future<void> getRestaurant() async {
    if (_customerAuth == null) throw APIRequestError(401, "Not logged in!");
    restaurant = Restaurant.fromJson(
        jsonDecode(await _sendRequest("/restaurants/${_customerAuth!.phone}")));
    notifyListeners();
  }

  Future<void> editRestaurant(Restaurant newRestaurant) async {
    await _sendRequest(
      "/restaurants/${restaurant!.phone}",
      method: "PATCH",
      body: newRestaurant.toJson(),
      authRequired: true,
    );
    restaurant = newRestaurant;
    notifyListeners();
  }

  Future<void> putNewImage({required String name, required XFile file}) async {
    await _sendRequest(
      "/restaurants/${restaurant!.phone}",
      method: "PUT",
      body: {"name": name},
      file: file,
      contentType: HttpBodyType.multipartForm,
      authRequired: true,
    );
  }

  Future<List<BaseOrderInOrder>> getRestaurantOrders() async {
    final orders =
        jsonDecode(await _sendRequest("/orders/restaurant", authRequired: true))
            as List<dynamic>;
    return [for (final order in orders) BaseOrderInOrder.fromJson(order)];
  }

  Future<OrderInOrder> getRestaurantOrder({required String id}) async {
    return OrderInOrder.fromJson(jsonDecode(await _sendRequest(
      "/orders/restaurant/$id",
      authRequired: true,
    )));
  }

  Future<RestaurantRating> getRestaurantRating() async {
    return RestaurantRating.fromJson(jsonDecode(
        await _sendRequest("/restaurants/${restaurant!.phone}/stats/rating")));
  }

  Future<RestaurantRevenue> getRestaurantRevenue() async {
    return RestaurantRevenue.fromJson(jsonDecode(await _sendRequest(
      "/restaurants/${restaurant!.phone}/stats/revenue",
      authRequired: true,
    )));
  }

  Future<void> setRestaurantOrderStatus({
    required String id,
    required OrderStatus status,
  }) async {
    await _sendRequest(
      "/orders/restaurant/$id/status",
      method: "PATCH",
      body: status.name,
      contentType: HttpBodyType.plainText,
    );
  }

  String getRestaurantImageUri({
    required String restaurant,
    required String filename,
  }) {
    return Uri.encodeFull("http://$_apiRoot/static/imgs/$restaurant/$filename");
  }
}
