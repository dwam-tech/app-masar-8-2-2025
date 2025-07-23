class MenuSection {
  final String name;
  final List<MenuItem> items;

  MenuSection({required this.name, required this.items});
}

class MenuItem {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<MenuOption> options;
  final double basePrice;

  MenuItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.options,
    required this.basePrice,
  });
}

class MenuOption {
  final String label;
  final double price;

  MenuOption({required this.label, required this.price});
}
