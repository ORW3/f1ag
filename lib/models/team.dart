import 'dart:convert';

class Team {
  Team({
    required this.car,
    required this.team_logo1,
    required this.team_logo2,
    required this.team_name,
    this.id,
  });

  String car;
  String team_logo1;
  String team_logo2;
  String team_name;
  int? id;

  factory Team.fromJson(String str) => Team.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Team.fromMap(Map<String, dynamic> json) => Team(
      car: json["car"],
      team_logo1: json["team_logo1"],
      team_logo2: json["team_logo2"],
      team_name: json["team_name"]);

  Map<String, dynamic> toMap() => {
        "car": car,
        "team_logo1": team_logo1,
        "team_logo2": team_logo2,
        "team_name": team_name,
      };

  Team copy() => Team(
      car: this.car,
      team_logo1: this.team_logo1,
      team_logo2: this.team_logo2,
      team_name: this.team_name,
      id: this.id);
}
