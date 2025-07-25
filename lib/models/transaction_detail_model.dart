class TransactionDetailModel {
  int id;
  int productId;
  String productName;
  int quantity;
  double price;
  double subtotal;

  TransactionDetailModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product']['product_name'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}
