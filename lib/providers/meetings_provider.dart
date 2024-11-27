import 'package:flutter/material.dart';
import 'package:f1ag/services/api_service.dart';

class MeetingsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _meetings = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> get meetings => _meetings;
  bool get isLoading => _isLoading;

  Future<void> loadMeetings() async {
    if (_meetings.isNotEmpty) return;
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final year = DateTime.now().year;
      final fetchedMeetings = await _apiService.fetchMeetingsByYear(year);
      _meetings = List<Map<String, dynamic>>.from(fetchedMeetings);
    } catch (error) {
      print("Error loading meetings: $error");
    }

    _isLoading = false;
    notifyListeners();
  }
}
