import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/Mcq/bookmark_service.dart';
import 'package:rogzarpath/constant/AppConstant.dart';
import 'package:rogzarpath/constant/model.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<MCQ> bookmarkedMCQs = [];

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final data = await BookmarkService.loadBookmarks();
    setState(() {
      bookmarkedMCQs = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        title: Text(
          "📑 Bookmarked Questions",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: MyColors.appbar,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: bookmarkedMCQs.isEmpty
          ? Center(
              child: Text(
                "No bookmarked questions found.",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedMCQs.length,
              itemBuilder: (context, index) {
                final mcq = bookmarkedMCQs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Q${index + 1}. ${mcq.question}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...['A', 'B', 'C', 'D'].map((label) {
                          final text = {
                            'A': mcq.optionA,
                            'B': mcq.optionB,
                            'C': mcq.optionC,
                            'D': mcq.optionD,
                          }[label]!;

                          final isCorrect = label == mcq.correctOption;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isCorrect ? Colors.green.shade100 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCorrect ? Colors.green : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isCorrect ? Colors.green : Colors.grey.shade400,
                                  child: Text(label, style: const TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    text,
                                    style: GoogleFonts.poppins(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Colors.deepPurple, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mcq.explanation,
                                style: GoogleFonts.poppins(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
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
