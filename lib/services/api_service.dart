import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://api.openf1.org/v1';

  Future<int> fetchLastSessionKey() async {
    final response = await http.get(Uri.parse('$baseUrl/drivers'));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return data.isNotEmpty ? data.last['session_key'] as int : -1;
    } else {
      throw Exception('Error al obtener la clave de sesión');
    }
  }

  Future<List<dynamic>> fetchDriversBySessionKey(int sessionKey) async {
    final response =
        await http.get(Uri.parse('$baseUrl/drivers?session_key=$sessionKey'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception('Error al obtener los conductores');
    }
  }

  Future<List<dynamic>> fetchDriversByLastSessionKey() async {
    final response =
        await http.get(Uri.parse('$baseUrl/drivers?session_key=latest'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception('Error al obtener los conductores');
    }
  }

  Future<List<dynamic>> fetchSessionsByYears(int year) async {
    final response = await http.get(
        Uri.parse('$baseUrl/sessions?year>=${year - 1}&year<=${year + 1}'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception('Error al obtener las sesiones');
    }
  }

  Future<List<dynamic>> fetchSessions() async {
    final response = await http.get(Uri.parse('$baseUrl/sessions'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception('Error al obtener las sesiones');
    }
  }

  Future<List<dynamic>> fetchMeetingsByYear(int year) async {
    final response = await http.get(Uri.parse('$baseUrl/meetings?year=$year'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception('Error al obtener las meetings');
    }
  }

  Future<List<dynamic>> getPositions() async {
    final response =
        await http.get(Uri.parse('$baseUrl/position?session_key=latest'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception('Error al obtener las posiciones');
    }
  }

  Future<List<dynamic>> getPositionsBySessionKey(int sessionKey) async {
    final response =
        await http.get(Uri.parse('$baseUrl/position?session_key=$sessionKey'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    } else {
      throw Exception('Error al obtener las posiciones');
    }
  }

  Future<Map<String, dynamic>> getLastWeatherBySessionKey(
      int sessionKey) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather?session_key=$sessionKey'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data.isNotEmpty) {
        return data.last as Map<String, dynamic>;
      } else {
        throw Exception('No se encontró el clima.');
      }
    } else {
      throw Exception('Error al obtener el clima');
    }
  }

  Future<Map<String, dynamic>> fetchLastCar(int driver) async {
    final url =
        Uri.parse('$baseUrl/car_data?session_key=latest&driver_number=$driver');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          return data.last as Map<String, dynamic>;
        } else {
          throw Exception('No se encontró información del automóvil.');
        }
      } else {
        throw Exception('${response.statusCode}');
      }
    } on FormatException {
      throw Exception('Formato de datos inválido.');
    } on SocketException {
      throw Exception('Error de conexión.');
    } catch (e) {
      throw Exception('Error desconocido: $e');
    }
  }
}
