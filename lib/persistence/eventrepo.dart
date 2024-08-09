import 'package:flutter/services.dart';
import 'package:ndovaj/models/event_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EventRepo{
  static final DateTime CUSTOM_DATE = DateTime.parse("1999-01-01T00:00:00Z");
  static final DateTime DEFAULT_LAST_EVENT_UPDATE = 
      DateTime.parse("2024-08-08T7:45:45Z");
  
  DateTime lastEventUpdate = DEFAULT_LAST_EVENT_UPDATE;
  List<Event> events = [];
  List<Event> nearbyEvents = [];

  String error = "";

  late String _cachedNewEv;
  late DateTime _cachedNewDate;

  Future<String> loadString() async{
    final prefs = await SharedPreferences.getInstance();

    lastEventUpdate = DateTime.parse(prefs.getString("lastEventUpdate") ?? DEFAULT_LAST_EVENT_UPDATE.toString());

    final String resp = await rootBundle.loadString('assets/events.json');
    final data = await json.decode(resp);


    return data;
  }

  Future<void> load() async {
    String data = await loadString();
    parse(data);
  }

  Future<DateTime> getLastEventFileDate() async{
    DateTime date ;
    http.Repsonse response = await http.get(Uri.parse(
      'https://api.github.com/repos/cronoimpius/ndovaj/commits?path=events.json&page=1&per_page=1'
    ));

    try {
      List<dynamic> json = jsonDecode(response.body);
      String dateString = json[0]['commit']['author']['date'];
      date = DateTime.parse(dateString);

      _cachedNewDate = date;

      return date;
    } catch (e) {
      print("Error: $e");

      return Future.error(e);
    }
  }

   /// Returns true if there is a more recent questions file
  Future<(bool, DateTime)> checkQuestionUpdates() async {
    DateTime date = await getLastEventFileDate();
    String content = await downloadFile();
    
    _cachedNewDate = date;

    return (date.isAfter(lastEventUpdate), date);
  }

  Future<String> downloadFile(
      [url = 
          "https://raw.githubusercontent.com/cronoimpius/ndovaj/main/assets/events.json"]) async {
    String result = "";

    // Get file content from repo
    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      result = response.body;

      _cachedNewEv = result;
    }

    return result;
  }

  void updateEventDate([DateTime? newDate]) async {
    final prefs = await SharedPreferences.getInstance();

    DateTime date;
    if (newDate != null) {
      date = newDate;
    } else {
      date = _cachedNewDate;
    }

    // Update shared preferences
    prefs.setString("lastEventUpdate", date.toString());

    // Load date to repository
    lastEventUpdate = date;
  }

  /// Overwrite questions file
  Future<bool> updateEventFile([String? newContent]) async {
    String content;

    // Check if it's valid
    if (newContent != null) {
      content = newContent;
    } else {
      content = _cachedNewEv;
    }
    
    // Update file
    

    // Load to repository
    parse(content);

    return true;
  }

  Future<void> update() async {
    updateEventDate();
    await updateEventFile();
  }

  // Parse a string and save each question in the repository
  void parse(String content) async {
    events.clear();
    nearbyEvents.clear();
    error = "";

    //List eventList = [];
    //events = List<Event>.from(content["events"] as List);
   
  }

  List<Event> getQuestions() {
    return events;
  }
}