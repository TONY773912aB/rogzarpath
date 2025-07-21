import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rogzarpath/api_service.dart';
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
        // Save locally
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', user.uid);
        await prefs.setString('name', user.displayName ?? '');
        await prefs.setString('email', user.email ?? '');
        await prefs.setString('photoUrl', user.photoURL ?? '');

        // Save to MySQL via PHP
        await saveUserToMySQL(user.displayName ?? '', user.email ?? '', user.uid, user.photoURL ?? '');

        return user;
      }
    } catch (e) {
      print("Google Sign-in failed: $e");
    }
    return null;
  }
  
  Future<void> saveUserToMySQL(String name, String email, String googleId, String photo) async {
    final uri = Uri.parse("http://10.161.153.180/rozgarapp/save_user.php"); // Update for host/production
    try {
      await http.post(uri, body: {
        'name': name,
        'email': email,
        'google_id': googleId,
        'photo': photo,
      });
    } catch (e) {
      print("Error saving user to MySQL: $e");
    }
  }
}
