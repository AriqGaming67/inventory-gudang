class AppItem {
  final String id;
  final String name;
  final String? sku;
  final String? description;
  final String? imageUrl;
  final int stock; // Joined from inventory table

  AppItem({
    required this.id,
    required this.name,
    this.sku,
    this.description,
    this.imageUrl,
    this.stock = 0,
  });

  factory AppItem.fromJson(Map<String, dynamic> json) {
    // Inventory is often returned as a list or map depending on the join
    int currentStock = 0;
    if (json['inventory'] != null) {
      if (json['inventory'] is List && json['inventory'].isNotEmpty) {
        currentStock = json['inventory'][0]['quantity'] ?? 0;
      } else if (json['inventory'] is Map) {
        currentStock = json['inventory']['quantity'] ?? 0;
      }
    }

    return AppItem(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      description: json['description'],
      imageUrl: json['image_url'],
      stock: currentStock,
    );
  }
}
