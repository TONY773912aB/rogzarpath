import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/model.dart';

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
    _futureQuestions = ApiService.fetchDailyQuiz();
  }

  void _nextQuestion(int total) {
    if (_currentIndex < total - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  Future<void> _submit(List<DailyQuizQuestion> questions) async {
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

    bool success = await ApiService.submitDailyQuiz(
      userId: UserTable.googleId,
      totalQuestions: total,
      attempted: attempted,
      correct: correct,
      wrong: wrong,
    );
    print("print ....................");
    print(success);
   showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    title: Row(
      children: [
        Icon(success ? Icons.check_circle : Icons.error, color: success ? Colors.green : Colors.red),
        SizedBox(width: 8),
        Text(
          success ? "Quiz Submitted 🎉" : "Submission Failed ❌",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: success ? Colors.green[800] : Colors.red[800],
          ),
        ),
      ],
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(thickness: 1),
        SizedBox(height: 8),
        Text(
          "You answered $correct out of $total correctly!",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Icon(Icons.emoji_events, color: Colors.amber, size: 40),
        SizedBox(height: 8),
      ],
    ),
    actions: [
      Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.check, color: Colors.white),
          label: Text("Continue", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: success ? Colors.green : Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {
            Navigator.pop(context);
            if (success) Navigator.pop(context);
          },
        ),
      ),
      SizedBox(height: 12),
    ],
  ),
);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        iconTheme: IconThemeData(
    color: Colors.white, // Change this to your desired color
  ),
        title: Text("📝 Daily Quiz",style: GoogleFonts.poppins(color: Colors.white),),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<DailyQuizQuestion>>(
        future: _futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("🚫 ${snapshot.error}"));
          if (snapshot.hasData && snapshot.data!.isEmpty)
            return Center(child: Text("📭 No questions found"));

          if (!snapshot.hasData) return SizedBox();

          final question = snapshot.data![_currentIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                /// ✅ Progress Bar
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / snapshot.data!.length,
                  color: Colors.indigo,
                  backgroundColor: Colors.grey.shade300,
                ),
                SizedBox(height: 20),

                /// ✅ Question Counter
                Text(
                  "Question ${_currentIndex + 1} of ${snapshot.data!.length}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),

                /// ✅ Question Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      question.question,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                /// ✅ Options
                ...["A", "B", "C", "D"].map((opt) {
                  String text = {
                    "A": question.optionA,
                    "B": question.optionB,
                    "C": question.optionC,
                    "D": question.optionD,
                  }[opt]!;

                  bool isSelected = _selectedAnswers[question.id] == opt;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo.shade100 : Colors.white,
                      border: Border.all(
                          color: isSelected
                              ? Colors.indigo
                              : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        "$opt. $text",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedAnswers[question.id] = opt;
                        });
                      },
                    ),
                  );
                }),

                Spacer(),

                /// ✅ Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.arrow_back,color: Colors.white,),
                      onPressed: _currentIndex > 0 ? _prevQuestion : null,
                      label: Text("Previous",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                      ),
                    ),
                    _currentIndex == snapshot.data!.length - 1
                        ? ElevatedButton.icon(
                            icon: Icon(Icons.check_circle,color: Colors.white,),
                            label: Text("Submit",style: TextStyle(color: Colors.white),),
                            onPressed: () => _submit(snapshot.data!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          )
                        : ElevatedButton.icon(
                            icon: Icon(Icons.arrow_forward,color: Colors.white,),
                            label: Text("Next",style: TextStyle(color: Colors.white),),
                            onPressed: () => _nextQuestion(snapshot.data!.length),
                            style: ElevatedButton.styleFrom(
                              
                              backgroundColor: Colors.indigo,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
