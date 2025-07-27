import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';

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
        title: Text(
          "Job Details",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
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

            // HTML content rendering
            HtmlWidget(
              content,
              textStyle: const TextStyle(fontSize: 16),
              customStylesBuilder: (element) {
                switch (element.localName) {
                  case 'table':
                    return {
                      'width': '100%',
                      'border-collapse': 'collapse',
                      'background-color': '#f9f9f9',
                      'border': '1px solid #bbb',
                    };
                  case 'th':
                    return {
                      'padding': '12px',
                      'background-color': '#4CAF50',
                      'color': 'white',
                      'font-weight': 'bold',
                      'text-align': 'left',
                      'border': '1px solid #ccc',
                    };
                  case 'td':
                    return {
                      'padding': '10px',
                      'border': '1px solid #ccc',
                      'font-size': '15px',
                      'color': '#333',
                    };
                  case 'p':
                    return {
                      'font-size': '16px',
                      'color': '#444',
                      'line-height': '1.6',
                    };
                }
                return null;
              },
              onTapUrl: (url) async {
                final uri = Uri.tryParse(url ?? '');
                if (uri != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening link: $url')),
                  );
                }
                return true;
              },
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
