import 'package:flutter/material.dart';
import 'package:f1ag/services/api_service.dart';

class DriversProvider with ChangeNotifier {
  List<Map<String, dynamic>> _drivers = [];
  List<Map<String, dynamic>> _positions = [];
  bool _isLoading = false;
  bool _isLoading1 = false;
  final ApiService _apiService = ApiService();
  int indexDriver = 0;

  List<Map<String, dynamic>> get drivers => _drivers;
  List<Map<String, dynamic>> get positions => _positions;
  bool get isLoading => _isLoading;
  bool get isLoading1 => _isLoading1;

  Future<void> loadDrivers() async {
    if (_drivers.isNotEmpty) return;
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final fetchedDrivers = await _apiService.fetchDriversByLastSessionKey();
      _drivers = List<Map<String, dynamic>>.from(fetchedDrivers);
    } catch (error) {
      print("Error loading drivers: $error");
    }

    _isLoading = false;
    notifyListeners();
  }

  void setIndex(int newIndex) {
    indexDriver = newIndex;
    notifyListeners();
  }

  Future<void> loadPositions() async {
    if (_positions.isNotEmpty) return;
    if (_isLoading1) return;

    _isLoading1 = true;
    notifyListeners();

    try {
      final fetchedPositions = await _apiService.getPositions();
      _positions = List<Map<String, dynamic>>.from(fetchedPositions);
    } catch (error) {
      print("Error loading positions: $error");
    }

    _isLoading1 = false;
    notifyListeners();
  }

  Future<void> loadPositionsBySessionKey(int sessionKey) async {
    //if (_positions.isNotEmpty) return;
    if (_isLoading1) return;

    _isLoading1 = true;
    notifyListeners();

    try {
      final fetchedPositions =
          await _apiService.getPositionsBySessionKey(sessionKey);
      _positions = List<Map<String, dynamic>>.from(fetchedPositions);
    } catch (error) {
      print("Error loading positions: $error");
    }

    _isLoading1 = false;
    notifyListeners();
  }
}
