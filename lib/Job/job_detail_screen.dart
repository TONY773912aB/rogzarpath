import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
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

  void shareJob() {
    final link = job?['link'] ?? '';
    Share.share('Check out this job opportunity:\n$link');
  }
  Future<bool> onTapUrl(BuildContext context, String? url) async {
  try {
    final uri = Uri.tryParse(url ?? '');
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open the link")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error opening link: $e")),
    );
  }
  return true;
}


  @override
  Widget build(BuildContext context) {
    final mediaUrl = job?['jetpack_featured_media_url'] ?? job?['better_featured_image']?['source_url'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.jobTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          //   onPressed: toggleFavorite,
          //   tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          // ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: shareJob,
            tooltip: 'Share job',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mediaUrl != null && mediaUrl.isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        mediaUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 40),
        ),
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
                  const SizedBox(height: 12),
                  Divider(color: Colors.indigo.shade100),
                  HtmlWidget(
                    job!['content']['rendered'],
                    textStyle: const TextStyle(fontSize: 16),
                 // onTapUrl: (url) => onTapUrl(context, url)
                 onTapUrl: (url) async {
  print("Tapped URL: $url"); // <-- Add this line
  if (url == null || url.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Invalid URL")),
    );
    return true;
  }

  try {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open the link")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error opening link: $e")),
    );
  }
  return true;
}

,
                    customStylesBuilder: (element) {
                      switch (element.localName) {
                        case 'table':
                          return {
                            'width': '100%',
                            'border-collapse': 'collapse',
                            'background-color': '#f9f9f9',
                            'border': '1px solid #bbb',
                          };
                        case 'thead':
                          return {'background-color': '#e0e0e0'};
                        case 'tr':
                          return {
                            'border-bottom': '1px solid #ddd',
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
                            'text-align': 'left',
                            'font-size': '15px',
                            'color': '#333',
                          };
                        case 'h1':
                          return {
                            'font-size': '24px',
                            'font-weight': 'bold',
                            'color': '#2c3e50',
                          };
                        case 'h2':
                          return {             
                            'font-size': '22px',
                            'font-weight': 'bold',
                            'color': '#2c3e50',
                          };
                        case 'h3':
                          return {
                            'font-size': '20px',
                            'font-weight': 'bold',
                            'color': '#34495e',
                          };
                        case 'p':
                          return {
                            'font-size': '16px',
                            'color': '#444',
                            'line-height': '1.6',
                          };
                        case 'ul':
                        case 'ol':
                          return {
                            'padding-left': '20px',
                            'font-size': '16px',
                          };
                        case 'li':
                          return {
                            'margin-bottom': '8px',
                          };
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
