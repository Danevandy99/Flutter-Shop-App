import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus() async {
    final oldStatus = isFavorite;
    final url = Uri.parse(
        'https://flutter-shop-app-994c1-default-rtdb.firebaseio.com/products/$id');

    // Update UI
    isFavorite = !isFavorite;
    notifyListeners();

    try {
      var await http.patch(
        url,
        body: json.encode({
          'favorite': isFavorite,
        }),
      );
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
