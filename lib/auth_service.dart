import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rogzarpath/api_service.dart';
import 'package:rogzarpath/constant/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
          String? idToken = await user.getIdToken();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('idToken', idToken??'');
        await prefs.setString('uid', user.uid);
        await prefs.setString('name', user.displayName ?? '');
        await prefs.setString('email', user.email ?? '');
        await prefs.setString('photoUrl', user.photoURL ?? '');

        // Save to class variable
      UserTable.setUser(
        id: user.uid,
        userName: user.displayName ?? '',
        userEmail: user.email ?? '',
        userPhoto: user.photoURL ?? '',
      );

        // Save to MySQL via PHP
        await saveUserToMySQL(user.displayName ?? '', user.email ?? '', user.uid, user.photoURL ?? '');

        return user;
      }
    } catch (e) {
      print("Google Sign-in failed: $e");
    }
    return null;
  }
  

Future<void> saveUserToMySQL(String name, String email, String googleId, String photoUrl) async {
  final uri = Uri.parse("${ApiService.appUrl}save_user.php");

  try {
    final response = await http.post(
      uri,
      body: {
        'name': name,
        'email': email,
        'google_id': googleId,
        'photo_url': photoUrl,
      },
    );

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          print("✅ Server says: ${jsonResponse['message']}");
        } else {
          print("⚠️ Server error: ${jsonResponse['message']}");
        }
      } catch (e) {
        print("⚠️ Failed to decode server response: ${response.body}");
      }
    } else {
      print("❌ HTTP error: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  } catch (e) {
    print("❌ Exception while saving user to MySQL: $e");
  }
}



}
