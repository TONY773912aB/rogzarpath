// mcq_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/model.dart';


class MCQScreen extends StatefulWidget {
  final String examId;
  final String subjectId;
  final String subjectName;
  final String userId;

  const MCQScreen({
    required this.examId,
    required this.subjectId,
     required this.subjectName,
    required this.userId,
    super.key,
  });

  @override
  State<MCQScreen> createState() => _MCQScreenState();
}

class _MCQScreenState extends State<MCQScreen> {
  List<MCQ> mcqs = [];
  bool isLoading = true;
  

  @override
  void initState() {
    super.initState();
    fetchMCQs();
  }

  Future<void> fetchMCQs() async {
    final url = Uri.parse("${ApiService.appUrl}get_mcqs.php");
    final response = await http.post(url, body: {
      'exam_id': widget.examId,
      'subject_id': widget.subjectId,
      'user_id': widget.userId,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status']) {
        setState(() {
          mcqs = List<MCQ>.from(data['data'].map((q) => MCQ.fromJson(q)));
          isLoading = false;
        });
      } else {
        showError("No MCQs found.");
        print("No MCQs found.");
      }
    } else {
      showError("Failed to load MCQs.");
      print("Failed to load MCQs.");
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void submitAnswer(int index) {
    final mcq = mcqs[index];
    if (mcq.selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an option.")),
      );
      return;
    }

    setState(() {}); // Triggers explanation display
  }

  void toggleBookmark(int index) {
    setState(() {
      mcqs[index].isBookmarked = !mcqs[index].isBookmarked;
    });

    // Optionally: Send API call to update backend
  }

  Widget buildOption(MCQ mcq, String option, String label, int index) {
    final isCorrect = mcq.selectedOption != null && label == mcq.correctOption;
    final isWrong = mcq.selectedOption == label && label != mcq.correctOption;

    return RadioListTile<String>(
      title: Text(
        option,
        style: TextStyle(
          color: isCorrect
              ? Colors.green
              : isWrong
                  ? Colors.red
                  : Colors.black,
        ),
      ),
      value: label,
      groupValue: mcq.selectedOption,
      onChanged: mcq.selectedOption == null
          ? (value) {
              setState(() {
                mcqs[index].selectedOption = value;
              });
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: mcqs.length,
              itemBuilder: (context, index) {
                final mcq = mcqs[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 20),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Q${index + 1}. ${mcq.question}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                mcq.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: mcq.isBookmarked ? Colors.orange : Colors.grey,
                              ),
                              onPressed: () => toggleBookmark(index),
                            )
                          ],
                        ),
                        buildOption(mcq, mcq.optionA, 'A', index),
                        buildOption(mcq, mcq.optionB, 'B', index),
                        buildOption(mcq, mcq.optionC, 'C', index),
                        buildOption(mcq, mcq.optionD, 'D', index),
                        const SizedBox(height: 10),
                        if (mcq.selectedOption == null)
                          ElevatedButton(
                            onPressed: () => submitAnswer(index),
                            child: Text("Submit Answer"),
                          ),
                        if (mcq.selectedOption != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Correct Answer: ${mcq.correctOption}",
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text("Explanation: ${mcq.explanation}"),
                            ],
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
