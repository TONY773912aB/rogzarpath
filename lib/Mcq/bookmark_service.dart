import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rogzarpath/constant/model.dart';

class BookmarkService {
  static const _key = 'bookmarked_mcqs';

  static Future<void> saveBookmarks(List<MCQ> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = bookmarks.map((mcq) => jsonEncode(mcq.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }

  static Future<List<MCQ>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final storedList = prefs.getStringList(_key) ?? [];
    return storedList.map((e) => MCQ.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> addBookmark(MCQ mcq) async {
    final bookmarks = await loadBookmarks();
    bookmarks.add(mcq);
    await saveBookmarks(bookmarks);
  }

  static Future<void> removeBookmark(String question) async {
    final bookmarks = await loadBookmarks();
    bookmarks.removeWhere((mcq) => mcq.question == question);
    await saveBookmarks(bookmarks);
  }

  static Future<bool> isBookmarked(String question) async {
    final bookmarks = await loadBookmarks();
    return bookmarks.any((mcq) => mcq.question == question);
  }
}
