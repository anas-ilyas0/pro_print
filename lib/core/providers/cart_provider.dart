import 'package:flutter/material.dart';
import 'package:proprint/core/models/cart_model.dart';
import 'package:proprint/core/theme/app_colors.dart';
import 'package:proprint/core/utils/widgets/widgets.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount => _items.fold(0, (sum, item) => sum + item.total);

  void addItem(CartItem item, BuildContext context) {
    if (item.stock == 0) {
      Widgets.customSnackbar(context, AppColors.red, '0 piece available');
      return;
    }

    final index = _items.indexWhere((element) => element.id == item.id);

    if (index != -1) {
      if (_items[index].quantity < _items[index].stock) {
        _items[index].quantity++;
        notifyListeners();
      } else {
        Widgets.customSnackbar(context, AppColors.red, 'Stock limit reached');
      }
    } else {
      _items.add(item);
      notifyListeners();
      Widgets.customSnackbar(
          context, AppColors.blueGrey, '${item.name} added to cart');
    }
  }

  void increaseQuantity(String id, BuildContext context) {
    final index = _items.indexWhere((element) => element.id == id);
    if (index != -1) {
      final item = _items[index];
      if (item.quantity < item.stock) {
        item.quantity++;
        notifyListeners();
      } else {
        Widgets.customSnackbar(
            context, AppColors.red, 'Only ${item.stock} pieces available');
      }
    }
  }

  void decreaseQuantity(String id) {
    final index = _items.indexWhere((element) => element.id == id);
    if (index != -1 && _items[index].quantity > 1) {
      _items[index].quantity--;
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
