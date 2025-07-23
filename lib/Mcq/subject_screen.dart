import 'package:flutter/material.dart';
import 'package:rogzarpath/Mcq/mcq_screen.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/model.dart';

class SubjectScreen extends StatefulWidget {
  final String examId;
  final String examName;

  const SubjectScreen({required this.examId, required this.examName});

  @override
  _SubjectScreenState createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  List subjects = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadSubjects();
    print("📦 Sending exam_id = ${widget.examId}");
  }

  Future<void> loadSubjects() async {
    try {
      final fetchedSubjects = await ApiService.getSubjects(widget.examId);
      setState(() {
        subjects = fetchedSubjects;
        print(subjects);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        print(errorMessage);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.examName} Subjects'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    itemCount: subjects.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MCQScreen(
                                examId: widget.examId,
                                subjectId: subject['id'].toString(),
                                subjectName: subject['name'],
                                userId: UserTable.googleId, // You can pass userId if needed
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange, Colors.deepOrangeAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.book,
                                      size: 40, color: Colors.white),
                                  SizedBox(height: 12),
                                  Text(
                                    subject['name'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
