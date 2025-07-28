class ProductModel {
  final int? id;
  final String productName;
  final int categoryId;
  final int supplierId;
  final double price;
  final int stock;
  final String? image;

  ProductModel({
    this.id,
    required this.productName,
    required this.categoryId,
    required this.supplierId,
    required this.price,
    required this.stock,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      productName: json['product_name'],
      categoryId: json['category_id'],
      supplierId: json['supplier_id'],
      price: double.parse(json['price'].toString()),
      stock: json['stock'],
      image: json['image'],
    );
  }

  String? get imageUrl {
    if (image == null) return null;
    return 'http://192.168.1.89:8000/storage/$image'; // sesuaikan IP kamu
  }
}
