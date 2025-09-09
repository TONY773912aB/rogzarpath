import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:rogzarpath/constant/AppConstant.dart';
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
  Map<int, String> userAnswers = {}; // questionId -> selected option
  Set<int> visitedQuestions = {}; // track visited questions
  Set<int> markedForReview = {}; // track marked questions
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

    final List<Map<String, dynamic>> answers = userAnswers.entries
        .map((entry) => {
              'question_id': entry.key,
              'selected_option': entry.value,
            })
        .toList();

    final DateTime endTime = DateTime.now();

    final result = await submitMockTest(
      userId: UserTable.googleId,
      testId: widget.test.id,
      startTime: startTime,
      endTime: endTime,
      answers: answers,
    );

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
    required String userId,
    required int testId,
    required DateTime startTime,
    required DateTime endTime,
    required List<Map<String, dynamic>> answers,
  }) async {
    final url = Uri.parse('${ApiService.appUrl}/submit_mock_test.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': UserTable.googleId,
          'test_id': testId,
          'start_time': startTime.toIso8601String().substring(0, 19).replaceFirst('T', ' '),
          'end_time': endTime.toIso8601String().substring(0, 19).replaceFirst('T', ' '),
          'answers': answers,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return {
            'success': true,
            'score': data['score'],
            'correct': data['correct'],
            'wrong': data['wrong'],
            'accuracy': data['accuracy'],
            'submission_id': data['submission_id'],
          };
        } else {
          return {'success': false, 'message': data['message']};
        }
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
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
        onChanged: (val) {
          setState(() => userAnswers[qid] = val!);
        },
        title: Text(text, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  // ✅ Build Question Palette Modal
  void showQuestionPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Text("Question Palette", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    int qid = questions[index].id;

                    // Decide color
                    Color bgColor = Colors.grey;
                    if (userAnswers.containsKey(qid)) {
                      bgColor = Colors.green; // Answered
                    }
                    if (markedForReview.contains(qid)) {
                      bgColor = Colors.blue; // Marked
                    }
                    if (!visitedQuestions.contains(qid)) {
                      bgColor = Colors.grey; // Not visited
                    }

                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          currentIndex = index;
                          visitedQuestions.add(qid);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text("${index + 1}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  legendBox(Colors.grey, "Not Visited"),
                  legendBox(Colors.red, "Not Answered"),
                  legendBox(Colors.green, "Answered"),
                  legendBox(Colors.blue, "Marked"),
                  legendBox(Colors.purple, "Answered & Marked"),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: submitTest,
                child: Text("Submit Test"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget legendBox(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 18, height: 18, color: color),
        const SizedBox(width: 6),
        Text(text),
      ],
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
    visitedQuestions.add(q.id);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Mock Test", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: MyColors.appbar,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Chip(
              backgroundColor: Colors.white,
              label: Text(
                "${secondsLeft ~/ 60}:${(secondsLeft % 60).toString().padLeft(2, '0')}",
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, color: Colors.white),
            tooltip: isPaused ? "Resume Test" : "Pause Test",
            onPressed: () => setState(() => isPaused = !isPaused),
          ),
        ],
      ),
      body: Padding(
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

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentIndex > 0)
                  ElevatedButton(
                    onPressed: () => setState(() => currentIndex--),
                    child: Text("⟵ Previous", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ElevatedButton(
                  onPressed: currentIndex < questions.length - 1
                      ? () => setState(() => currentIndex++)
                      : submitTest,
                  child: Text(currentIndex < questions.length - 1 ? "Next ⟶" : "Submit ✅",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: showQuestionPalette,
  backgroundColor: Colors.deepPurple,
  child: Icon(Icons.grid_view, color: Colors.white),
),

    );
  }
}

