//Displayed list of products available in a JSON
class ProductModel {
  final String name;
  final int id;
  final double cost;
  final bool availability;
  final String details;
  final String category;
  int quantity;

  ProductModel({
    required this.name,
    required this.id,
    required this.cost,
    required this.availability,
    required this.details,
    required this.category,
    this.quantity = 0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      name: json['p_name'],
      id: json['p_id'],
      cost: json['p_cost'].toDouble(),
      availability: json['p_availability'] == 1 ? true : false,
      details: json['p_details'] ?? '',
      category: json['p_category'] ?? '',
      quantity: 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'p_name': name,
      'p_id': id,
      'p_cost': cost,
      'p_availability': availability,
      'p_details': details,
      'p_category': category,
      'p_quantity': quantity,
    };
  }
}
