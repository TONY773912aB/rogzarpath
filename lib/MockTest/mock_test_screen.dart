import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:rogzarpath/constant/model.dart';
import 'mock_test_result_screen.dart';

class MockTestScreen extends StatefulWidget {
  final MockTest test;
  const MockTestScreen({required this.test});

  @override
  _MockTestScreenState createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  List<MockQuestion> questions = [];
  Map<int, String> userAnswers = {};
  int currentIndex = 0;
  late Timer _timer;
  int secondsLeft = 0;
  bool isPaused = false;
  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    loadQuestions();
  }

  void loadQuestions() async {
    questions = await MockTestService.getQuestions(widget.test.id);
    secondsLeft = widget.test.duration * 60;
    startTimer();
    setState(() {});
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (!isPaused) {
        setState(() {
          secondsLeft--;
        });
        if (secondsLeft <= 0) {
          submitTest();
        }
      }
    });
  }

void submitTest() async {
  _timer.cancel();

  // Build the answers list from userAnswers map
  final List<Map<String, dynamic>> answers = userAnswers.entries
      .map((entry) => {
            'question_id': entry.key,
            'selected_option': entry.value,
          })
      .toList();

  // Set end time
  final DateTime endTime = DateTime.now();

  // You can replace this with dynamic user ID
  final int userId = 1; // 🔁 Change this if using auth or SharedPreferences

  // Submit to server
  final result = await submitMockTest(
    userId: userId,
    testId: widget.test.id,
    startTime: startTime,
    endTime: endTime,
    answers: answers,
  );

  // Handle result
  if (result['success']) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MockTestResultScreen(
          score: result['score'],
          total: questions.length,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('❌ Submission failed: ${result['message']}')),
    );
  }
}




Future<Map<String, dynamic>> submitMockTest({
  required int userId,
  required int testId,
  required DateTime startTime,
  required DateTime endTime,
  required List<Map<String, dynamic>> answers, // List of {'question_id': 1, 'selected_option': 'A'}
}) async {
  final url = Uri.parse('http://10.161.153.180/rozgarapp/submit_mock_test.php'); // 🔁 Change to your actual URL

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'test_id': testId,
        'start_time': startTime.toIso8601String().substring(0, 19).replaceFirst('T', ' '),
        'end_time': endTime.toIso8601String().substring(0, 19).replaceFirst('T', ' '),
        'answers': answers,
      }),
    );

    if (response.statusCode == 200) {
      print("🔁 Response: ${response.body}");

      final data = jsonDecode(response.body);
      if (data['success']) {
        print("✅ Submission successful");
        return {
          'success': true,
          'score': data['score'],
          'correct': data['correct'],
          'wrong': data['wrong'],
          'accuracy': data['accuracy'],
          'submission_id': data['submission_id'],
        };
      } else {
        print("⚠️ Submission failed: ${data['message']}");
        return {'success': false, 'message': data['message']};
      }
    } else {
      print("❌ HTTP error: ${response.statusCode}");
      return {'success': false, 'message': 'Server error'};
    }
  } catch (e) {
    print("❌ Exception during submission: $e");
    return {'success': false, 'message': 'Exception: $e'};
  }
}


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget buildOptionTile(String option, String text, int qid) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: RadioListTile<String>(
        activeColor: Colors.deepPurple,
        value: option,
        groupValue: userAnswers[qid],
        onChanged: (val) => setState(() => userAnswers[qid] = val!),
        title: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
      );
    }

    final q = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
      
        title: Text("Mock Test", style: TextStyle(color: Colors.white),),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple, Colors.indigo]),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Chip(
              backgroundColor: Colors.white,
              label: Text(
                "${secondsLeft ~/ 60}:${(secondsLeft % 60).toString().padLeft(2, '0')}",
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Q${currentIndex + 1}/${questions.length}",
                          style: TextStyle(fontSize: 16, color: Colors.deepPurple)),
                      const SizedBox(height: 8),
                      Text(q.question,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Options
                buildOptionTile("A", q.optionA, q.id),
                buildOptionTile("B", q.optionB, q.id),
                buildOptionTile("C", q.optionC, q.id),
                buildOptionTile("D", q.optionD, q.id),

                const Spacer(),

                // Pause/Resume toggle
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => isPaused = !isPaused),
                    icon: Icon(isPaused ? Icons.play_arrow : Icons.pause,color: Colors.white,),
                    label: Text(isPaused ? "Resume Test" : "Pause Test",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPaused ? Colors.green : Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: StadiumBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentIndex > 0)
                      ElevatedButton(
                        onPressed: () => setState(() => currentIndex--),
                        child: Text("⟵ Previous",style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: currentIndex < questions.length - 1
                          ? () => setState(() => currentIndex++)
                          : submitTest,
                      child: Text(currentIndex < questions.length - 1 ? "Next ⟶" : "Submit ✅",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
