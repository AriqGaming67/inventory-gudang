class StockMovement {
  final String id;
  final String itemId;
  final String type;
  final int quantity;
  final String? note;
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    this.note,
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'],
      itemId: json['item_id'],
      type: json['type'],
      quantity: json['quantity'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
