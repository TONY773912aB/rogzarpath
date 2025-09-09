import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rogzarpath/constant/AppConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rogzarpath/api_service.dart';
import 'job_bookmark_detail_screen.dart';

class BookmarkedJobsScreen extends StatefulWidget {
  const BookmarkedJobsScreen({super.key});

  @override
  State<BookmarkedJobsScreen> createState() => _BookmarkedJobsScreenState();
}

class _BookmarkedJobsScreenState extends State<BookmarkedJobsScreen> {
  List<dynamic> bookmarkedJobs = [];
  List<String> bookmarkedJobIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBookmarkedJobs();
  }

  void loadBookmarkedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    bookmarkedJobIds = prefs.getStringList('favouriteJobs') ?? [];

    if (bookmarkedJobIds.isNotEmpty) {
      final fetchedJobs = await ApiService.fetchJobs();

      bookmarkedJobs = fetchedJobs.where((job) {
        return bookmarkedJobIds.contains(job['id'].toString());
      }).toList();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (bookmarkedJobs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Bookmarked Jobs"),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: Text(
            "No bookmarked jobs found.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmarked Jobs",style: GoogleFonts.poppins(color: Colors.white,),),
        backgroundColor: MyColors.appbar,
        centerTitle: true,
        iconTheme: IconThemeData(
    color: Colors.white, // Change this to your desired color
  ),
        elevation: 4,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookmarkedJobs.length,
        itemBuilder: (context, index) {
          final job = bookmarkedJobs[index];
          final title = job['title']['rendered'];
          final date = DateFormat('dd MMM yyyy').format(DateTime.parse(job['date']));

          return GestureDetector(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => JobBookmarkDetailScreen(jobData: job),
              //   ),
              // );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.bookmark, color: Colors.deepPurple.shade700),
                ),
                title: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "📅 Published: $date",
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
