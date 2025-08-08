import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:rogzarpath/constant/AppConstant.dart';

class JobBookmarkDetailScreen extends StatelessWidget {
  final Map<String, dynamic> jobData;

  const JobBookmarkDetailScreen({super.key, required this.jobData});

  @override
  Widget build(BuildContext context) {
    final title = jobData['title']?['rendered'] ?? 'No Title';
    final content = jobData['content']?['rendered'] ?? 'No Content';
    final date = jobData['date'] != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(jobData['date']))
        : 'N/A';

    final mediaUrl = jobData['jetpack_featured_media_url'] ??
        jobData['better_featured_image']?['source_url'];

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
    color: Colors.white, // Change this to your desired color
  ),
        title:  Text(
          "Job Details",
          style: GoogleFonts.poppins(fontWeight: FontWeight.normal,color:Colors.white),
        ),
        backgroundColor: MyColors.appbar,
        centerTitle: true,
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured image
            if (mediaUrl != null && mediaUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  mediaUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade900,
                  ),
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.indigo.shade100),

            // Metadata Table
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  _buildRow("Published On", date),
                  _buildRow("Job Type", jobData['job_type'] ?? 'Full-Time'),
                  _buildRow("Location", jobData['location'] ?? 'Not specified'),
                  _buildRow("Category", jobData['category'] ?? 'General'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Job Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            /// 🔽 HTML content rendering with flutter_html
            Html(
              data: content,
              style: {
                "body": Style(
                  fontSize: FontSize(16),
                  color: Colors.black87,
                  lineHeight: LineHeight(1.6),
                ),
                "table": Style(
                  backgroundColor: const Color(0xFFF9F9F9),
                  border: Border.all(color: const Color(0xFFBBBBBB)),
                ),
                "th": Style(
                  padding: HtmlPaddings.all(12),
                  backgroundColor: Colors.deepPurple.shade300,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.left,
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                ),
                "td": Style(
                  padding: HtmlPaddings.all(10),
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                  fontSize: FontSize(15),
                  color: const Color(0xFF333333),
                ),
              },
              // onLinkTap: (url, _, __, ___) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text('Opening link: $url')),
              //   );
              // },
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(String key, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Text(
            "$key:",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Text(value),
        ),
      ],
    );
  }
}
