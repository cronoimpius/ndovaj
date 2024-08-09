import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static const bool DEFAULT_CHECK_APP_UPDATE = true;
  static const bool DAFAULT_CHECK_EVENT_UPDATE = true;

  late bool checkAppUpdate = DEFAULT_CHECK_APP_UPDATE;
  late bool checkEventUpdate  = DAFAULT_CHECK_EVENT_UPDATE;

  void loadFromSharedPreferences () async {
    final prefs = await SharedPreferences.getInstance();

    checkAppUpdate = prefs.getBool("checkAppUpdate") ?? DEFAULT_CHECK_APP_UPDATE;
    checkEventUpdate = prefs.getBool("checkEventUpdate") ?? DAFAULT_CHECK_EVENT_UPDATE;
  }

  void saveToSharedPreferences () async{
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool("checkAppUpdate", checkAppUpdate);
    prefs.setBool("checkEventUpdate", checkEventUpdate);
  }

  void resetDefault () async{
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool("checkAppUpdate", DEFAULT_CHECK_APP_UPDATE);
    prefs.setBool("checkEventUpdate", DAFAULT_CHECK_EVENT_UPDATE);
  }
}