// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rogzarpath/constant/model.dart';

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


class MockTestService {
  static const baseUrl = 'http://10.161.153.180/rozgarapp/';

static Future<List<MockTest>> getTests(int examId) async {
  final response = await http.post(
    Uri.parse('${baseUrl}get_mock_tests.php'),
    body: {'exam_id': examId.toString()}, // Always send as string
  );

  if (response.statusCode == 200) {
    try {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        List<dynamic> testList = data['data'];
        return testList.map((e) => MockTest.fromJson(e)).toList();
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      print('Error parsing response: $e');
      print('Raw response: ${response.body}');
      throw Exception("Invalid response format");
    }
  } else {
    throw Exception('Failed to load tests');
  }
}



 static Future<List<MockQuestion>> getQuestions(int testId) async {
  final response = await http.post(
    Uri.parse('${baseUrl}get_mock_test_questions.php'),
    body: {'test_id': testId.toString()},
  );

  print('🔍 Raw response: ${response.body}');

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);

    print('🧪 Decoded JSON: $decoded');

    if (decoded["status"] == true && decoded["questions"] != null) {
      final questionsData = decoded["questions"];
      return List<MockQuestion>.from(
        questionsData.map((e) => MockQuestion.fromJson(e)),
      );
    } else {
      throw Exception("No questions found or invalid response.");
    }
  } else {
    throw Exception('Failed to load questions');
  }
}


static Future<String> submitTest(Map<String, dynamic> submissionData) async {
    final response = await http.post(
      Uri.parse('${baseUrl}submit_mock_test.php'),
      body: json.encode(submissionData),
      headers: {'Content-Type': 'application/json'},
    );
    

    if (response.statusCode == 200) {    
      return response.body;
    } else {
      throw Exception('Submission failed');
    }
  }
}

