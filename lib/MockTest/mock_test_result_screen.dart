import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rogzarpath/MockTest/mockTestAnswersScreen.dart';
import 'package:rogzarpath/api_service.dart';

class MockTestResultScreen extends StatelessWidget {
  final int submissionId;
  final int score;
  final int total;
  final int correct;
  final int wrong;
  final int unattempted;
  final String timeTaken;

  const MockTestResultScreen({
    super.key,
    required this.submissionId,
    required this.score,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.unattempted,
    required this.timeTaken,
  });

  Future<List<Map<String, dynamic>>> fetchSubmissionAnswers(int submissionId) async {
  final url = Uri.parse("${ApiService.appUrl}get_mock_test_answers.php?submission_id=$submissionId");

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['status'] == 'success') {
      // Convert List<dynamic> → List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception("Failed: ${data['message'] ?? 'Unknown error'}");
    }
  } else {
    throw Exception("HTTP error: ${response.statusCode}");
  }
}

  @override
  Widget build(BuildContext context) {
    double percentage = (score / total) * 100;
    String status = percentage >= 50 ? "Great Job!" : "Needs Improvement";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Test Summary", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.purpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      "Your Score",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "$score / $total",
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      color: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.3),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      status,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Details Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InfoRow(label: "Time Taken", value: timeTaken),
                    Divider(),
                    InfoRow(label: "Total Questions", value: "$total"),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ResultBox(label: "Correct", value: correct, color: Colors.green),
                        ResultBox(label: "Wrong", value: wrong, color: Colors.red),
                        ResultBox(label: "Unanswered", value: unattempted, color: Colors.grey),
                      ],
                    )
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Buttons
            ElevatedButton.icon(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              icon: Icon(Icons.home,color: Colors.white,),
              label: Text("Back to Home", style: GoogleFonts.poppins(fontSize: 16,color:Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 12),
           OutlinedButton.icon(
  onPressed: () async {
    // Example API fetch (replace with your API call)
    final answers = await fetchSubmissionAnswers(submissionId); 
    print("answer printed.....................................");
    print(answers);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MockTestAnswersScreen(answers: answers),
      ),
    );
  },
  icon: Icon(Icons.list, color: Colors.deepPurple),
  label: Text("View Answers", style: GoogleFonts.poppins(fontSize: 16, color: Colors.deepPurple)),
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: Colors.deepPurple),
    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
),

          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.poppins(fontSize: 16)),
        ],
      ),
    );
  }
}

class ResultBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const ResultBox({super.key, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString(),
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 14)),
      ],
    );
  }
}
