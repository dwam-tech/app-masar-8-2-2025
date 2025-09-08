class CartItem {
  final int menuItemId;
  final String name;
  final double price;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
    'menu_item_id': menuItemId,
    'quantity': quantity,
  };

  CartItem copyWith({
    int? menuItemId,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.menuItemId == menuItemId;
  }

  @override
  int get hashCode => menuItemId.hashCode;
}