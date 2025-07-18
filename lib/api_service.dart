// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {  
  static const String baseUrl = 'https://gyankikhoj.in/wp-json/wp/v2';

  static Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load categories');
    }
  }

 Future<Map<String, dynamic>> fetchJobById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load job details');
    }
  }




  static Future<List<dynamic>> fetchJobs({int? categoryId}) async {
    final url = categoryId == null
        ? '$baseUrl/posts?per_page=50'
        : '$baseUrl/posts?categories=$categoryId&per_page=50';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load jobs');
    }
  }
}
