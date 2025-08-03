import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/AppConstant.dart';
import 'package:rogzarpath/constant/model.dart';
import 'mock_test_screen.dart';

class MockTestListScreen extends StatefulWidget {
  final int examId;
  final String examName;

  const MockTestListScreen({required this.examId, required this.examName});

  @override
  _MockTestListScreenState createState() => _MockTestListScreenState();
}

class _MockTestListScreenState extends State<MockTestListScreen> {
  late Future<List<MockTest>> futureTests;

  @override
  void initState() {
    super.initState();
    futureTests = MockTestService.getTests(widget.examId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         iconTheme: IconThemeData(
    color: Colors.white, // Change this to your desired color
  ),
        title: Text(
          widget.examName,
          style: GoogleFonts.poppins(color: Colors.white)
        ),
        backgroundColor: MyColors.appbar,
        centerTitle: true,
      ),
      body: FutureBuilder<List<MockTest>>(
        future: futureTests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No mock tests found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final tests = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            itemBuilder: (_, index) {
              final test = tests[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MockTestScreen(test: test),
                    ),
                  );
                },
                child: Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade50, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.quiz, size: 36, color: Colors.deepPurple),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Duration: ${test.duration} mins",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                "Marks: ${test.totalMarks}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.deepPurple),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
