import 'package:flutter/material.dart';

class PagesProvider with ChangeNotifier {
  bool _isAgendaTap = false;

  bool get isAgendaTap => _isAgendaTap;

  void changeIsAgendaTap(bool value) {
    _isAgendaTap = value;
  }
}
