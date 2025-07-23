import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'news_service.dart';

class DailyNewsScreen extends StatefulWidget {
  @override
  _DailyNewsScreenState createState() => _DailyNewsScreenState();
}

class _DailyNewsScreenState extends State<DailyNewsScreen> {
  bool isHindi = false; // ✅ Boolean to control language
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() {
  setState(() {
    _newsFuture = NewsService.fetchCurrentAffairs(language: isHindi ? 'hi' : 'en');
  });
}

void _toggleLanguage(bool value) {
  setState(() {
    isHindi = value;
    _loadNews(); // Refresh news when language changes
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Daily Current Affairs"),
       leading: IconButton(
    icon: Icon(Icons.arrow_back), // or Icons.arrow_back_ios
    onPressed: () {
      Navigator.pop(context); // 👈 goes back to the previous screen
    },
  ),
        backgroundColor: Colors.deepPurple,
        actions: [
          Row(
            children: [
              Text("EN", style: TextStyle(color: Colors.white)),
              Switch(
                value: isHindi,
                onChanged: _toggleLanguage,
                activeColor: Colors.white,
                inactiveThumbColor: Colors.grey,
              ),
              Text("हिंदी", style: TextStyle(color: Colors.white)),
              SizedBox(width: 8),
            ],
          )
        ],
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text("Error loading news"));

          final news = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: news.length,
            itemBuilder: (context, index) {
              final item = news[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Icon(Icons.fiber_manual_record,
                        color: Colors.deepPurple),
                  ),
                  title: Text(
                    item.title,
                    style:  GoogleFonts.notoSansDevanagari(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "Source: ${item.source}",
                    style: GoogleFonts.notoSansDevanagari(color: Colors.grey[700]),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.open_in_new, color: Colors.deepPurple),
                    onPressed: () => _launchURL(item.link),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open link")),
      );
    }
  }
}
