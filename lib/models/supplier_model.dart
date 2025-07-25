class SupplierModel {
  final int id;
  final String supplierName;
  final String phone;
  final String address;

  SupplierModel({
    required this.id,
    required this.supplierName,
    required this.phone,
    required this.address,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'],
      supplierName: json['supplier_name'],
      phone: json['phone'],
      address: json['address'],
    );
  }
}
