class Item {
  final String id;
  final String name;
  final String? sku;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final int quantity;

  Item({
    required this.id,
    required this.name,
    this.sku,
    this.description,
    this.imageUrl,
    required this.createdAt,
    this.quantity = 0,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
