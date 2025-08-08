import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogzarpath/constant/AppConstant.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api_service.dart';

class JobDetailScreen extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const JobDetailScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Map<String, dynamic>? job;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadJobDetails();
    checkFavoriteStatus();
  }

  Future<void> checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorite_jobs') ?? [];
    setState(() {
      isFavorite = favs.contains(widget.jobId.toString());
    });
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorite_jobs') ?? [];

    if (favs.contains(widget.jobId.toString())) {
      favs.remove(widget.jobId.toString());
    } else {
      favs.add(widget.jobId.toString());
    }

    await prefs.setStringList('favorite_jobs', favs);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> loadJobDetails() async {
    try {
      final apiService = ApiService();
      final fetchedJob = await apiService.fetchJobById(widget.jobId);
      setState(() {
        job = fetchedJob;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading job: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load job details')),
      );
    }
  }

  Future<bool> onTapUrl(BuildContext context, String? url) async {
    if (url == null) return false;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
      return false;
    }
  }



  Widget buildHtmlContent(String? htmlContent) {
    return Html(
      data: htmlContent ?? "",
     /// extensions: const [TableHtmlExtension()],
     
      onLinkTap: (url, attributes, element) => onTapUrl(context, url),
      style: {
        "html": Style(fontSize: FontSize(16.0)),
        "table": Style(
          backgroundColor: Colors.white,
          border: Border.all(color: Colors.black),
          padding: HtmlPaddings.all(8),
        ),
        "th": Style(
          backgroundColor: Colors.indigo,
          color: Colors.white,
          padding: HtmlPaddings.all(10),
          fontWeight: FontWeight.w600,
        ),
        "td": Style(
          padding: HtmlPaddings.all(10),
          border: Border.all(color: Colors.grey.shade300),
          fontSize: FontSize(15),
          color: Colors.black87,
        ),
        "tr": Style(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        "h1": Style(
          fontSize: FontSize(24),
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2c3e50),
        ),
        "h2": Style(
          fontSize: FontSize(22),
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2c3e50),
        ),
        "h3": Style(
          fontSize: FontSize(20),
          fontWeight: FontWeight.bold,
          color: const Color(0xFF34495e),
        ),
        "p": Style(
          fontSize: FontSize(16),
          color: const Color(0xFF444444),
          lineHeight: LineHeight(1.6),
        ),
        "ul": Style(
          padding: HtmlPaddings.only(left: 20),
          fontSize: FontSize(16),
        ),
        "ol": Style(
          padding: HtmlPaddings.only(left: 20),
          fontSize: FontSize(16),
        ),
        "li": Style(
          margin: Margins.only(bottom: 8),
        ),
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final mediaUrl = job?['jetpack_featured_media_url'] ??
        job?['better_featured_image']?['source_url'];

    return Scaffold(
      appBar: AppBar(
         iconTheme: IconThemeData(
    color: Colors.white, // Change this to your desired color
  ),
        backgroundColor: MyColors.appbar,
        title: Text(
          widget.jobTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(color:Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: toggleFavorite,
            tooltip: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mediaUrl != null && mediaUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        mediaUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    job!['title']['rendered'],
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade900,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: buildHtmlContent(job?['content']['rendered']),
                  ),
                ],
              ),
            ),
    );
  }
}
