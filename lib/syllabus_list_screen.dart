import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/AppConstant.dart';
import 'package:rogzarpath/constant/model.dart';
import 'pdf_viewer_screen.dart';

class SyllabusListScreen extends StatefulWidget {
  const SyllabusListScreen({super.key});

  @override
  State<SyllabusListScreen> createState() => _SyllabusListScreenState();
}

class _SyllabusListScreenState extends State<SyllabusListScreen> {
  late Future<List<SyllabusPDF>> futurePDFs;

  @override
  void initState() {
    super.initState();
    futurePDFs = ApiService.fetchSyllabusPDFs();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        iconTheme: IconThemeData(
    color: Colors.white, // Change this to your desired color
  ),
        title:  Text(
          "📚 Exam Syllabus PDFs",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
            
          ),
        ),
        centerTitle: true,
      backgroundColor: MyColors.appbar,
        elevation: 0,
      ),
      body: FutureBuilder<List<SyllabusPDF>>(
        future: futurePDFs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          } else if (snapshot.hasError) {
            return Center(
              child: Text("❌ Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No syllabus PDFs found.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Group by exam name
          final grouped = <String, List<SyllabusPDF>>{};
          for (var item in snapshot.data!) {
            grouped.putIfAbsent(item.examName, () => []).add(item);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            children: grouped.entries.map((entry) {
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    leading: const Icon(Icons.school, color: Colors.deepPurple),
                    title: Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    children: entry.value.map((pdf) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                            title: Text(
                              pdf.pdfTitle,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PDFViewerScreen(pdf: pdf),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
