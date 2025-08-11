import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static Future<bool> isAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    return email == 'info@proprint.com.cy';
  }
}
