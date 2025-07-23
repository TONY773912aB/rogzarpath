// news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsItem {
  final String title;
  final String link;
  final String source;

  NewsItem({required this.title, required this.link, required this.source});

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      source: json['source_id'] ?? '',
    );
  }
}

class NewsService {
  static const String _apiKey = "pub_73958babb8f34d16bb9737585762296d";

  static Future<List<NewsItem>> fetchCurrentAffairs({String language = 'en'}) async {
    final url = Uri.parse(
      "https://newsdata.io/api/1/news?apikey=$_apiKey&q=current%20affairs&language=$language",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8Body = utf8.decode(response.bodyBytes); // ✅ Fix Hindi/UTF text
      final jsonData = json.decode(utf8Body);
      final List articles = jsonData['results'] ?? [];

      return articles.map((json) => NewsItem.fromJson(json)).toList();
    } else {
      throw Exception("❌ Failed to load current affairs. Status: ${response.statusCode}");
    }
  }
}
