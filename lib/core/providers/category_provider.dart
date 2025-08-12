import 'package:flutter/material.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

class Category {
  final int id;
  final String name;
  final String imageUrl;
  Category({required this.id, required this.name, required this.imageUrl});
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'] ?? '',
      imageUrl: map['image_url'] ?? '',
    );
  }
}

class CategoryProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      notifyListeners();

      // final userId = supabase.auth.currentUser?.id;
      // if (userId == null) throw Exception("User not logged in");

      final response =
          await supabase.from('categories').select(); //.eq('user_id', userId);

      final data = response as List;

      _categories = [
        Category(
          id: -1,
          name: 'Products',
          imageUrl: 'https://cdn-icons-png.flaticon.com/512/3081/3081559.png',
        ),
        ...data.map((e) => Category.fromMap(e))
      ];
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id, BuildContext context) async {
    try {
      final response = await supabase.from('categories').delete().eq('id', id);

      if (response != null) {
        _categories.removeWhere((category) => category.id == id);
        notifyListeners();
        Future.microtask(() {
          if (!context.mounted) return;
          Widgets.customSnackbar(
            context,
            AppColors.blueGrey,
            'Category deleted successfully!',
          );
        });
      }
    } catch (e) {
      print("Error deleting category: $e");
      Future.microtask(() {
        if (!context.mounted) return;
        Widgets.customSnackbar(
          context,
          AppColors.red,
          'Error: ${e.toString()}',
        );
      });
    }
  }
}
