import 'package:flutter/material.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String imageUrl;
  final String prodDesc;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.prodDesc,
  });
}

class ProductProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Product> _allProducts = [];
  bool _isLoading = false;
  String _selectedCategory = 'Products';
  String _searchQuery = '';

  List<Product> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get filteredProducts {
    return _allProducts.where((product) {
      final matchesCategory = _selectedCategory == 'Products' ||
          product.category == _selectedCategory;
      final matchesSearch =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    fetchProducts();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      // final userId = supabase.auth.currentUser?.id;
      // if (userId == null) throw Exception("User not logged in");

      final response = await supabase
          .from('products')
          .select()
          //.eq('user_id', userId)
          .ilike('category',
              _selectedCategory == 'Products' ? '%' : _selectedCategory);

      final data = response as List;

      _allProducts = data
          .map((e) => Product(
                id: e['id'],
                name: e['name'] ?? '',
                category: e['category'] ?? '',
                price: (e['price'] as num).toDouble(),
                quantity: e['quantity'] ?? 0,
                imageUrl: e['image_url'] ?? '',
                prodDesc: e['prodDesc'] ?? '',
              ))
          .toList();
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id, BuildContext context) async {
    try {
      final response = await supabase.from('products').delete().eq('id', id);

      if (response != null) {
        _allProducts.removeWhere((product) => product.id == id);
        notifyListeners();
      }
      if (!context.mounted) return;
      Widgets.customSnackbar(
          context, AppColors.blueGrey, 'Product deleted successfully!');
    } catch (e) {
      print("Error deleting product: $e");
      Widgets.customSnackbar(context, AppColors.red, 'Error: ${e.toString()}');
    }
  }
}
