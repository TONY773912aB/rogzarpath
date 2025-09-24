import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MockTestAnswersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> answers; // Pass API response here

  const MockTestAnswersScreen({super.key, required this.answers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("Your Answers", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: answers.length,
        itemBuilder: (context, index) {
          final q = answers[index];
          final selected = q['selected_option'];
          final correct = q['correct_ans'];

          Color optionColor(String optionKey) {
            if (optionKey == correct) return Colors.green; // Correct
            if (optionKey == selected && selected != correct) return Colors.red; // Wrong
            return Colors.grey.shade200;
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Q${index + 1}. ${q['question']}",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      buildOption("A", q['option_a'], selected, correct, optionColor),
                      buildOption("B", q['option_b'], selected, correct, optionColor),
                      buildOption("C", q['option_c'], selected, correct, optionColor),
                      buildOption("D", q['option_d'], selected, correct, optionColor),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildOption(String key, String text, String selected, String correct,
      Color Function(String) optionColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: optionColor(key),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Text(key, style: TextStyle(color: Colors.white)),
        ),
        title: Text(text, style: GoogleFonts.poppins(fontSize: 14)),
        trailing: key == correct
            ? Icon(Icons.check_circle, color: Colors.green)
            : (key == selected && selected != correct
                ? Icon(Icons.cancel, color: Colors.red)
                : null),
      ),
    );
  }
}
