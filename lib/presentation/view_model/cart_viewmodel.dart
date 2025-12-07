// // lib/presentation/viewmodels/cart_viewmodel.dart
// import 'package:flutter/foundation.dart';
// import 'package:onlineclothing_app/data/models/products.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class CartViewModel extends ChangeNotifier {
//   final supabase = Supabase.instance.client;
//   List<CartItem> cartItems = [];

//   Future<void> addToCart({
//     required Product product,
//     required int quantity,
//     required String size,
//     required String color,
//   }) async {
//     final userId = supabase.auth.currentUser?.id;
//     if (userId == null) return;

//     await supabase.from('cart').upsert({
//       'user_id': userId,
//       'product_id': product.id,
//       'quantity': quantity,
//       'size': size,
//       'color': color,
//     });

//     notifyListeners();
//   }

//   // Load cart, remove item, etc. can be added here
// }

// class CartItem {
//   final Product product;
//   final int quantity;
//   final String size;
//   final String color;

//   CartItem({
//     required this.product,
//     required this.quantity,
//     required this.size,
//     required this.color,
//   });
// }

import 'package:flutter/material.dart';
import 'package:onlineclothing_app/data/models/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String size;
  final String color;

  CartItem({
    required this.product,
    required this.quantity,
    required this.size,
    required this.color,
  });
}

class CartViewModel extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  // Total amount in cart
  double get totalAmount {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  // Add item to cart (or increase quantity if already exists)
  Future<void> addToCart({
    required Product product,
    required int quantity,
    required String size,
    required String color,
  }) async {
    final existingIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.size == size &&
          item.color == color,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex] = CartItem(
        product: product,
        quantity: _cartItems[existingIndex].quantity + quantity,
        size: size,
        color: color,
      );
    } else {
      _cartItems.add(
        CartItem(
          product: product,
          quantity: quantity,
          size: size,
          color: color,
        ),
      );
    }

    // Optional: save to Supabase cart table
    await _saveCartToSupabase();

    notifyListeners();
  }

  // Remove item completely
  void removeItem(int index) {
    _cartItems.removeAt(index);
    _saveCartToSupabase();
    notifyListeners();
  }

  // Clear entire cart — THIS WAS MISSING!
  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCartToSupabase();
    notifyListeners();
  }

  // Load cart from Supabase (optional – for multi-device sync)
  Future<void> loadCart() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('cart')
        .select('''
          quantity, size, color,
          product:product!inner(id, name, description, price, image_url, category, sizes, colors, stock)
        ''')
        .eq('user_id', user.id);

    _cartItems = response.map<CartItem>((item) {
      final prodJson = item['product'] as Map<String, dynamic>;
      return CartItem(
        product: Product.fromJson(prodJson),
        quantity: item['quantity'] as int,
        size: item['size'] as String,
        color: item['color'] as String,
      );
    }).toList();

    notifyListeners();
  }

  // Save cart to Supabase (optional)
  Future<void> _saveCartToSupabase() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // First delete old cart
    await Supabase.instance.client.from('cart').delete().eq('user_id', user.id);

    // Insert new items
    if (_cartItems.isNotEmpty) {
      final data = _cartItems
          .map(
            (item) => {
              'user_id': user.id,
              'product_id': item.product.id,
              'quantity': item.quantity,
              'size': item.size,
              'color': item.color,
            },
          )
          .toList();

      await Supabase.instance.client.from('cart').insert(data);
    }
  }
}
