import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:f1ag/models/team.dart';
import 'package:http/http.dart' as http;

class TeamService extends ChangeNotifier {
  final String _baseUrl = 'productos-flutter-b32cc-default-rtdb.firebaseio.com';
  final List<Team> teams = [];
  bool isLoading = true;

  TeamService() {
    this.obtenerTeams();
  }

  Future obtenerTeams() async {
    this.isLoading = true;

    final url = Uri.https(_baseUrl, 'f1teams.json');
    final resp = await http.get(url);
    final Map<String, dynamic> teamsMap = json.decode(resp.body);

    teamsMap.forEach((key, value) {
      final teamTemp = Team.fromMap(value);
      teamTemp.id = int.parse(key.replaceAll("t", ""));
      this.teams.add(teamTemp);
    });

    this.isLoading = false;
    notifyListeners();
  }

  Future<Team?> obtenerTeamPorNombre(String teamName) async {
    if (isLoading) await obtenerTeams();

    for (var team in teams) {
      if (team.team_name == teamName) {
        return team;
      }
    }
    return null;
  }
}
