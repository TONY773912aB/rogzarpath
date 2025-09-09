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
  Map<int, String> userAnswers = {};
  Set<int> visitedQuestions = {};
  Set<int> markedForReview = {};
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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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

String formatTime(int secondsLeft) {
  final minutes = secondsLeft ~/ 60;
  final seconds = secondsLeft % 60;
  return '${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')} min';
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
      print(result['success']);
      final int score = (result['score'] as num).toInt();
final int correct = (result['correct'] as num).toInt();
final int wrong = (result['wrong'] as num).toInt();
final int unattempted = questions.length - correct - wrong;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MockTestResultScreen(
           score: result['score'],
      total: questions.length,
      correct: result['correct'],
      wrong: result['wrong'],
      unattempted: unattempted,
      timeTaken: formatTime(secondsLeft),
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
          'start_time': startTime
              .toIso8601String()
              .substring(0, 19)
              .replaceFirst('T', ' '),
          'end_time': endTime
              .toIso8601String()
              .substring(0, 19)
              .replaceFirst('T', ' '),
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

  // ✅ Custom Option Tile (Modern Button Style)
  Widget buildOptionTile(String option, String text, int qid) {
    bool isSelected = userAnswers[qid] == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          userAnswers[qid] = option;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Colors.white, Colors.white],
                ),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  isSelected ? Colors.white : Colors.deepPurple.shade100,
              child: Text(
                option,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.deepPurple : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Question Palette
  void showQuestionPalette() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              Text("Question Palette",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    int qid = questions[index].id;

                    Color bgColor = Colors.grey;
                    if (userAnswers.containsKey(qid)) {
                      bgColor = Colors.green;
                    }
                    if (markedForReview.contains(qid)) {
                      bgColor = Colors.blue;
                    }
                    if (!visitedQuestions.contains(qid)) {
                      bgColor = Colors.grey.shade400;
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
                        child: Text("${index + 1}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
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
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: submitTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text("Submit Test",
                    style: TextStyle(color: Colors.white)),
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
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: Colors.deepPurple)),
      );
    }

    final q = questions[currentIndex];
    visitedQuestions.add(q.id);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Mock Test",
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: MyColors.appbar,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Chip(
              backgroundColor: Colors.white,
              shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
              label: Text(
                "${secondsLeft ~/ 60}:${(secondsLeft % 60).toString().padLeft(2, '0')}",
                style:  GoogleFonts.poppins(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white),
            tooltip: isPaused ? "Resume Test" : "Pause Test",
            onPressed: () => setState(() => isPaused = !isPaused),
          ),

           IconButton(
            icon: Icon(Icons.dashboard,
                color: Colors.white),
            
            onPressed: showQuestionPalette,
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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade200
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Q${currentIndex + 1}/${questions.length}",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(q.question,
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
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
                  ElevatedButton.icon(
                    onPressed: () => setState(() => currentIndex--),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label:  Text("Previous",style:  GoogleFonts.poppins(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: currentIndex < questions.length - 1
                      ? () => setState(() => currentIndex++)
                      : submitTest,
                  icon: Icon(
                    currentIndex < questions.length - 1
                        ? Icons.arrow_forward
                        : Icons.check,
                    color: Colors.white,
                  ),
                  label: Text(
                    currentIndex < questions.length - 1 ? "Next" : "Submit",
                    style:  GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: showQuestionPalette,
      //   backgroundColor: Colors.deepPurple,
      //   child: const Icon(Icons.grid_view, color: Colors.white),
      //   elevation: 6,
      //   shape:
      //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // ),
    );
  }
}
