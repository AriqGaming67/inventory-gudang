class StockMovement {
  final String id;
  final String? itemId;
  final String type;
  final int quantity;
  final String? note;
  final String? createdBy;
  final DateTime createdAt;

  // Field join
  final String? itemName;
  final String? createdByName;

  StockMovement({
    required this.id,
    this.itemId,
    required this.type,
    required this.quantity,
    this.note,
    this.createdBy,
    required this.createdAt,
    this.itemName,
    this.createdByName,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      itemId: json['item_id'] as String?,
      type: json['type'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      itemName: json['item_name'] as String?,
      createdByName: json['created_by_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'type': type,
      'quantity': quantity,
      'note': note,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
