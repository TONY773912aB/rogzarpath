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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: success
                  ? [Colors.green.shade400, Colors.green.shade700]
                  : [Colors.red.shade400, Colors.red.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                size: 70,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                success ? "Quiz Submitted 🎉" : "Submission Failed ❌",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You answered $correct / $total correctly",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.check, color: Colors.white),
                label: Text("Continue", style: GoogleFonts.poppins(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (success) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("📝 Daily Quiz", style: GoogleFonts.poppins(color: Colors.white, fontSize:18)),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: FutureBuilder<List<DailyQuizQuestion>>(
        future: _futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("🚫 ${snapshot.error}"));
          if (snapshot.hasData && snapshot.data!.isEmpty)
            return const Center(child: Text("📭 No questions found"));

          if (!snapshot.hasData) return const SizedBox();

          final question = snapshot.data![_currentIndex];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                /// ✅ Progress bar with percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Q ${_currentIndex + 1}/${snapshot.data!.length}",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "${((_currentIndex + 1) / snapshot.data!.length * 100).toInt()}%",
                      style: GoogleFonts.poppins(color: Colors.indigo),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / snapshot.data!.length,
                    minHeight: 10,
                    color: Colors.indigo,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 20),

                /// ✅ Question Card
                Card(
                  elevation: 6,
                  shadowColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      question.question,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// ✅ Options
                ...["A", "B", "C", "D"].map((opt) {
                  String text = {
                    "A": question.optionA,
                    "B": question.optionB,
                    "C": question.optionC,
                    "D": question.optionD,
                  }[opt]!;

                  bool isSelected = _selectedAnswers[question.id] == opt;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAnswers[question.id] = opt;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.indigo.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? Colors.indigo : Colors.grey.shade300,
                          width: 2,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                isSelected ? Colors.indigo : Colors.grey.shade300,
                            child: Text(opt,
                                style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              text,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.indigo),
                        ],
                      ),
                    ),
                  );
                }),

                const Spacer(),

                /// ✅ Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _currentIndex > 0 ? _prevQuestion : null,
                      label: Text("Previous", style: GoogleFonts.poppins(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                    _currentIndex == snapshot.data!.length - 1
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                            label: Text("Submit",
                                style: GoogleFonts.poppins(color: Colors.white)),
                            onPressed: () => _submit(snapshot.data!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            ),
                          )
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward, color: Colors.white),
                            label: Text("Next",
                                style: GoogleFonts.poppins(color: Colors.white)),
                            onPressed: () => _nextQuestion(snapshot.data!.length),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
