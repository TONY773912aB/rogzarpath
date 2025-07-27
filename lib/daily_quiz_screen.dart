import 'package:flutter/material.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DailyQuizScreen extends StatefulWidget {
  @override
  _DailyQuizScreenState createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  late Future<List<DailyQuizQuestion>> _futureQuestions;
  int _currentIndex = 0;
  Map<int, String> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _futureQuestions =  ApiService.fetchDailyQuiz();
  }

  void _nextQuestion(int total) {
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

 void _submit(List<DailyQuizQuestion> questions) async {
  int total = questions.length;
  int attempted = 0;
  int correct = 0;

  for (var q in questions) {
    if (_selectedAnswers.containsKey(q.id)) {
      attempted++;
      if (_selectedAnswers[q.id] == q.correctAns) correct++;
    }
  }

  int wrong = attempted - correct;

  // Dummy user_id; replace this with actual SharedPreferences value
  final prefs = await SharedPreferences.getInstance();
  int userId = int.parse(prefs.getString('UserId') ?? '0');

  bool success = await ApiService.submitDailyQuiz(
    userId:  int.parse(UserTable.googleId),
    totalQuestions: total,
    attempted: attempted,
    correct: correct,
    wrong: wrong,
  );

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(success ? "✅ Submitted" : "❌ Failed"),
      content: Text("You scored $correct out of $total"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (success) Navigator.pop(context); // Close quiz screen if successful
          },
          child: Text("OK"),
        )
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("📝 Daily Quiz", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<DailyQuizQuestion>>(
        future: _futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var question = snapshot.data![_currentIndex];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Question ${_currentIndex + 1}/${snapshot.data!.length}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text(question.question,
                      style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
                  SizedBox(height: 20),
                  ...["A", "B", "C", "D"].map((opt) {
                    String text = {
                      "A": question.optionA,
                      "B": question.optionB,
                      "C": question.optionC,
                      "D": question.optionD,
                    }[opt]!;

                    return Card(
                      color: _selectedAnswers[question.id] == opt
                          ? Colors.green[100]
                          : Colors.white,
                      child: ListTile(
                        title: Text("$opt. $text"),
                        onTap: () {
                          setState(() {
                            _selectedAnswers[question.id] = opt;
                          });
                        },
                      ),
                    );
                  }),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.arrow_back),
                        onPressed: _currentIndex > 0 ? _prevQuestion : null,
                        label: Text("Previous"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                      ),
                      _currentIndex == snapshot.data!.length - 1
                          ? ElevatedButton.icon(
                              icon: Icon(Icons.done),
                              onPressed: () => _submit(snapshot.data!),
                              label: Text("Submit"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            )
                          : ElevatedButton.icon(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () => _nextQuestion(snapshot.data!.length),
                              label: Text("Next"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                            ),
                    ],
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("🚫 ${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
