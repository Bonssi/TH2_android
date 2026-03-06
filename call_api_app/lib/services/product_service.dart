import 'dart:convert';

import 'package:call_api_app/models/product.dart';
import 'package:http/http.dart' as http;

class ProductService {
  static final Uri _productsUrl = Uri.parse('https://fakestoreapi.com/products');

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(_productsUrl);

      if (response.statusCode != 200) {
        throw Exception('Server trả về mã lỗi: ${response.statusCode}');
      }

      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw Exception('Không thể tải dữ liệu sản phẩm. Vui lòng kiểm tra mạng và thử lại.');
    }
  }
}
