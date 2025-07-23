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

  static Future<List<NewsItem>> fetchCurrentAffairs({bool isHindi = false}) async {
    final language = isHindi ? "hi" : "en";
    final url = Uri.parse("https://newsdata.io/api/1/news?apikey=$_apiKey&country=in&language=$language&category=top");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List articles = json.decode(response.body)['results'];
      return articles.map((e) => NewsItem.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load news");
    }
  }
}
