import 'package:onlineclothing_app/data/models/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository {
  final supabase = Supabase.instance.client;

  Stream<List<Product>> getProductsStream() {
    return Supabase.instance.client
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Product.fromJson(json)).toList());
  }

  Future<List<Product>> getProducts() async {
    final response = await supabase
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return response.map<Product>((data) => Product.fromJson(data)).toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final response = await supabase
        .from('products')
        .select()
        .eq('category', category);

    return response.map<Product>((data) => Product.fromJson(data)).toList();
  }
}
