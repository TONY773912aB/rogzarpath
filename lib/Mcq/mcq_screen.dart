import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:rogzarpath/Mcq/bookmark_service.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/AppConstant.dart';
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
  int currentIndex = 0;

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
      }
    } else {
      showError("Failed to load MCQs.");
    }
  }

  void showError(String message) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void toggleBookmark(int index) async {
    setState(() {
      mcqs[index].isBookmarked = !mcqs[index].isBookmarked;
    });

    if (mcqs[index].isBookmarked) {
      await BookmarkService.addBookmark(mcqs[index]);
    } else {
      await BookmarkService.removeBookmark(mcqs[index].question);
    }
  }

  void selectOption(String label) {
    if (mcqs[currentIndex].selectedOption != null) return;
    setState(() {
      mcqs[currentIndex].selectedOption = label;
    });
  }

  Widget buildOption(MCQ mcq, String text, String label) {
    bool isCorrect = mcq.selectedOption != null && label == mcq.correctOption;
    bool isWrong = mcq.selectedOption == label && label != mcq.correctOption;
    bool isSelected = mcq.selectedOption == label;

    Color bgColor;
    if (isCorrect) {
      bgColor = Colors.green.shade100;
    } else if (isWrong) {
      bgColor = Colors.red.shade100;
    } else if (isSelected) {
      bgColor = Colors.deepPurple.shade50;
    } else {
      bgColor = Colors.white;
    }

    Color borderColor;
    if (isCorrect) {
      borderColor = Colors.green;
    } else if (isWrong) {
      borderColor = Colors.red;
    } else if (isSelected) {
      borderColor = Colors.deepPurple;
    } else {
      borderColor = Colors.grey.shade300;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (isSelected || isCorrect || isWrong)
            BoxShadow(
              color: borderColor.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
        ],
      ),
      child: InkWell(
        onTap: () => selectOption(label),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: borderColor,
              radius: 14,
              child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isCorrect
                      ? Colors.green.shade900
                      : isWrong
                          ? Colors.red.shade900
                          : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> submitAttempts() async {
    final url = Uri.parse('${ApiService.appUrl}save_mcq_attempt.php');

    final attempts = mcqs
        .where((mcq) => mcq.selectedOption != null)
        .map((mcq) => {
              "question_id": mcq.id,
              "selected_option": mcq.selectedOption,
            })
        .toList();

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "user_id": UserTable.googleId,
        "attempts": attempts,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['status']) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("✅ Submitted"),
          content: const Text("Your answers have been submitted successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "Submission failed")),
      );
    }
  }

  // ✅ Question Palette (Bottom Sheet)
  void showQuestionPalette() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: mcqs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final mcq = mcqs[index];
              Color color;
              if (mcq.selectedOption != null) {
                color = Colors.green; // answered
              } else if (mcq.isBookmarked) {
                color = Colors.orange; // bookmarked
              } else {
                color = Colors.grey; // not answered
              }

              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() => currentIndex = index);
                },
                child: CircleAvatar(
                  backgroundColor: color,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mcq = mcqs.isNotEmpty ? mcqs[currentIndex] : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: MyColors.appbar,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.subjectName, style: GoogleFonts.poppins(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white),
            onPressed: showQuestionPalette,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mcqs.isEmpty
              ? const Center(child: Text("No MCQs found."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Q${currentIndex + 1}. ${mcq!.question}",
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            onPressed: () => toggleBookmark(currentIndex),
                            icon: Icon(
                              mcq.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: mcq.isBookmarked ? Colors.orange : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      buildOption(mcq, mcq.optionA, 'A'),
                      buildOption(mcq, mcq.optionB, 'B'),
                      buildOption(mcq, mcq.optionC, 'C'),
                      buildOption(mcq, mcq.optionD, 'D'),
                      const SizedBox(height: 16),
                      if (mcq.selectedOption != null) ...[
                        Text(
                          "✔ Correct Answer: ${mcq.correctOption}",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "📝 Explanation: ${mcq.explanation}",
                          style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: currentIndex > 0 ? () => setState(() => currentIndex--) : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: currentIndex > 0
                                    ? const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)])
                                    : const LinearGradient(colors: [Colors.grey, Colors.grey]),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: currentIndex > 0
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.arrow_back, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text("Previous", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (currentIndex < mcqs.length - 1) {
                                setState(() => currentIndex++);
                              } else {
                                if (UserTable.googleId == "" || UserTable.googleId == null || UserTable.googleId == "null") {
                                  print("User ID is Null/Empty............");
                                } else {
                                  submitAttempts();
                                }
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: currentIndex < mcqs.length - 1
                                    ? const LinearGradient(colors: [Color(0xFF43C6AC), Color(0xFF191654)])
                                    : const LinearGradient(colors: [Color(0xFF00B09B), Color(0xFF96C93D)]),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    currentIndex < mcqs.length - 1 ? "Next" : "Submit",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    currentIndex < mcqs.length - 1 ? Icons.arrow_forward : Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
    );
  }
}
