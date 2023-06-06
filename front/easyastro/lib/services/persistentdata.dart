import 'package:shared_preferences/shared_preferences.dart';


class PersistentData {

    Future<void> saveValue(String key, String value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }

    Future<String?> getValue(String key) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }

}