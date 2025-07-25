class CategoryModel {
  final int id;
  final String categoryName;

  CategoryModel({
    required this.id,
    required this.categoryName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      categoryName: json['category_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'category_name': categoryName,
      };
}
