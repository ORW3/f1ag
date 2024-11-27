import 'dart:collection';
import 'package:f1ag/pages/agenda_page.dart';
import 'package:flutter/material.dart';
import 'package:f1ag/services/api_service.dart';
import 'package:table_calendar/table_calendar.dart';

class SessionsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _sessionsMeetingKey = [];
  Map<String, dynamic> _weather = {};
  bool _isLoading = false;
  bool _isLoadingSessionsMeeting = false;
  bool _isLoadingWeather = false;
  final ApiService _apiService = ApiService();
  String _meetingOfficialName = "";

  final LinkedHashMap<DateTime, List<Event>> _events = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  List<Map<String, dynamic>> get sessions => _sessions;
  bool get isLoading => _isLoading;
  bool get isLoadingSessionsMeeting => _isLoadingSessionsMeeting;
  bool get isLoadingWeather => _isLoadingWeather;
  String get meetingOfficialName => _meetingOfficialName;
  List<Map<String, dynamic>> get sessionsMeetingKey => _sessionsMeetingKey;
  LinkedHashMap<DateTime, List<Event>> get events => _events;
  Map<String, dynamic> get weather => _weather;

  Future<void> loadSessions() async {
    if (_sessions.isNotEmpty) return;
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final fetchedSessions = await _apiService.fetchSessions();
      _sessions = List<Map<String, dynamic>>.from(fetchedSessions);
    } catch (error) {
      print("Error loading sessions: $error");
    }

    _loadEvents(_sessions);
    notifyListeners();
  }

  Future<void> getSessions(int meetingKey, String officialName) async {
    _isLoadingSessionsMeeting = true;
    _sessionsMeetingKey = [];
    _meetingOfficialName = officialName;
    for (var session in _sessions) {
      if (session["meeting_key"] == meetingKey) {
        _sessionsMeetingKey.add(session);
      }
    }
    _isLoadingSessionsMeeting = false;
  }

  // Cargar los eventos desde los datos de la API
  void _loadEvents(List<Map<String, dynamic>> sessionData) {
    for (var session in sessionData) {
      DateTime dateStart = DateTime.parse(session["date_start"]).toLocal();
      String sessionName = session["session_name"];

      // Añadir el evento al mapa
      if (_events[dateStart] == null) {
        _events[dateStart] = [];
      }
      _events[dateStart]!.add(Event(sessionName, session['session_type'],
          session['session_key'], session['date_start']));
    }

    _isLoading = false;
  }

  Future<void> getWeatherBySessionKey(int sessionKey) async {
    if (_isLoadingWeather) return;

    _isLoadingWeather = true;
    notifyListeners();

    _weather = {};

    try {
      final fetchedWeathers =
          await _apiService.getLastWeatherBySessionKey(sessionKey);
      _weather = Map<String, dynamic>.from(fetchedWeathers);
    } catch (error) {
      print("Error loading positions: $error");
    }

    _isLoadingWeather = false;
    notifyListeners();
  }
}
