// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {  

  static const String baseUrl = 'https://vacancygyan.in/wp-json/wp/v2';
  static const String appUrl = 'http://10.161.153.180/rozgarapp/';
  
   /// Fetch list of exams
  static Future<List<dynamic>> getExams() async {
    final url = Uri.parse("${appUrl}get_exams.php");

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      

      if (data['status']) {
        return data['data'];
      } else {
        throw Exception('No exams found.');
      }
    } catch (e) {
      throw Exception('Error fetching exams: $e');
    }
  }
   
 
static Future<List<dynamic>> getSubjects(String examId) async {
  final url = Uri.parse('${appUrl}get_subjects.php');
  print("exam id: $examId");
  
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
    body: {'exam_id': examId},
    encoding: Encoding.getByName("utf-8"),
  );

  print("Response: ${response.body}");

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    if (json['status'] == true) {
      return json['data'];
    } else {
      throw Exception(json['message'] ?? 'Unknown error');
    }
  } else {
    throw Exception('Failed to load subjects');
  }
}

 





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

  static getSubjectsByExam(String examId) {}
}
