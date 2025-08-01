class CartItem {
  final String id;
  final String name;
  final String image;
  final double price;
  final String description;
  final int stock;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.stock,
    this.quantity = 1,
  });

  double get total => price * quantity;
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'quantity': quantity,
      'total': total,
    };
  }
}
