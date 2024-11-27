import 'package:f1ag/main.dart';
import 'package:f1ag/providers/drivers_provider.dart';
import 'package:f1ag/providers/pages_provider.dart';
import 'package:f1ag/providers/sessions_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PosicionesPage extends StatefulWidget {
  const PosicionesPage({super.key});

  @override
  State<PosicionesPage> createState() => _PosicionesPageState();
}

class _PosicionesPageState extends State<PosicionesPage> {
  List<Map<String, dynamic>> raceData = [];

  int? selectedDriver;

  List<FlSpot> getDriverSpots(int driverNumber) {
    var driverData = raceData
        .where((data) => data['driver_number'] == driverNumber)
        .toList();

    var spots = driverData.map((data) {
      DateTime date = DateTime.parse(data['date']);
      double originalPosition = data['position'].toDouble();
      return FlSpot(
        date.millisecondsSinceEpoch.toDouble(),
        21 - originalPosition, // Invertir el valor de y
      );
    }).toList();

    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  String getBestPositionText(int driverNumber) {
    try {
      // Obtener la lista de posiciones originales en base a los valores invertidos de y
      final positions = getDriverSpots(driverNumber)
          .map((e) => (21 - e.y)
              .toInt()) // Revertimos el valor de y para la posición original
          .toList();
      if (positions.isNotEmpty) {
        final bestPosition = positions
            .reduce((a, b) => a < b ? a : b); // Obtener la mejor posición
        return '${bestPosition.toString()}°';
      } else {
        return 'No hay información';
      }
    } catch (e) {
      return 'No hay información';
    }
  }

  int getFinalPosition(int driverNumber) {
    try {
      // Obtener la lista de posiciones originales en base a los valores invertidos de y
      final positions = getDriverSpots(driverNumber)
          .map((e) => (21 - e.y)
              .toInt()) // Revertimos el valor de y para la posición original
          .toList();
      if (positions.isNotEmpty) {
        final finalPosition = positions.last; // Obtener la mejor posición
        return finalPosition;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionsProvider = Provider.of<SessionsProvider>(context);
    final driversProvider = Provider.of<DriversProvider>(context);
    Map<int, Color> driverColors = {};
    Map<int, String> driverNames = {};
    Map<int, String> driverTeams = {};
    final iconoTeams = {
      'McLaren':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728884781/mclaren-logo_smkcpj.png',
      'Ferrari':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728885329/ferrari-logo_izag9e.png',
      'Red Bull Racing':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728884749/red-bull-racing-logo_ztm1ui.png',
      'Mercedes':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728885410/mercedes-logo_tmcsll.png',
      'Aston Martin':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728885905/aston-martin-logo_ghphqh.png',
      'Alpine':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728886273/alpine-logo_c4pbzk.png',
      'Haas F1 Team':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728886079/haas-logo_s6objt.png',
      'RB':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728885990/rb-logo_qvds7c.png',
      'AlphaTauri':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728885990/rb-logo_qvds7c.png',
      'Williams':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728886150/williams-logo_ldqsw0.png',
      'Kick Sauber':
          'https://res.cloudinary.com/dogupuezd/image/upload/v1728886384/kick-sauber-logo_ozrwh1.png'
    };

    Map<String, dynamic>? getWinnerDriver() {
      if (driversProvider.drivers.isEmpty) return null;

      for (var driver in driversProvider.drivers) {
        int driverNumber = driver['driver_number'];
        if (getFinalPosition(driverNumber) == 1) {
          return {
            'name': driverNames[driverNumber] ?? 'No disponible',
            'team': driverTeams[driverNumber] ?? 'No disponible',
            'color': driverColors[driverNumber] ?? Colors.white,
            'number': driverNumber,
          };
        }
      }
      return null;
    }

    if (driversProvider.drivers.isNotEmpty) {
      for (var driver in driversProvider.drivers) {
        if (driver['team_colour'] == null) {
          driverColors[driver['driver_number']] = Colors.white;
        } else {
          driverColors[driver['driver_number']] =
              Color(int.parse("0xFF${driver['team_colour']}"));
        }
        driverNames[driver['driver_number']] =
            driver['full_name'] ?? 'No disponible';
        driverTeams[driver['driver_number']] =
            driver['team_name'] ?? 'No disponible';
      }

      raceData = driversProvider.positions;
    }

    String airTemperature = "";
    String humidity = "";
    String pressure = "";
    String rainfall = "";
    String trackTemperature = "";
    String windDirection = "";
    String windSpeed = "";

    if (sessionsProvider.weather.isNotEmpty &&
        sessionsProvider.isLoadingWeather == false) {
      airTemperature = sessionsProvider.weather['air_temperature'].toString();
      humidity = sessionsProvider.weather['humidity'].toString();
      pressure = sessionsProvider.weather['pressure'].toString();
      rainfall = sessionsProvider.weather['rainfall'].toString();
      trackTemperature =
          sessionsProvider.weather['track_temperature'].toString();
      windDirection = sessionsProvider.weather['wind_direction'].toString();
      windSpeed = sessionsProvider.weather['wind_speed'].toString();
    }

    final winnerDriver = getWinnerDriver();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (Provider.of<PagesProvider>(context, listen: false).isAgendaTap ==
            true) {
          mainPageKey.currentState?.navigateToPage(1);
        } else {
          mainPageKey.currentState?.navigateToPage(5);
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 35,
              ),
              const Text(
                'Posiciones',
                style: TextStyle(fontSize: 23, fontFamily: 'f1-bold'),
              ),
              const SizedBox(
                height: 25,
              ),
              driversProvider.drivers.isEmpty || driversProvider.isLoading1
                  ? Container(
                      padding: EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: LoadingAnimationWidget.inkDrop(
                        size: 40,
                        color: Color.fromARGB(255, 56, 56, 63),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (winnerDriver != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¡Ganador! 🏆',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Piloto: ${winnerDriver['name']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Equipo: ${winnerDriver['team']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Número: #${winnerDriver['number']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Dropdown para seleccionar piloto
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 56, 56, 63),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<int>(
                              value: selectedDriver,
                              hint: const Text('Seleccionar Piloto'),
                              isExpanded: true,
                              dropdownColor: Color.fromARGB(255, 56, 56, 63),
                              items: driverNames.entries.map((entry) {
                                return DropdownMenuItem<int>(
                                  value: entry.key,
                                  child: Row(
                                    children: [
                                      Image.network(
                                        iconoTeams[driverTeams[entry.key]] ??
                                            'https://res.cloudinary.com/dogupuezd/image/upload/v1732589834/20241125_205648_dekhgv.png',
                                        width: 16,
                                        height: 16,
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Icon(
                                            Icons.person_rounded,
                                            color: driverColors[entry.key],
                                            size: 16,
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        '#${entry.key} ${entry.value}',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDriver = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Gráfico
                          selectedDriver == null
                              ? Container(
                                  height: 20,
                                  child: Center(
                                    child: Text(
                                      'Selecciona un piloto para ver sus posiciones',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    SizedBox(
                                      height: 300,
                                      child: LineChart(
                                        LineChartData(
                                          lineTouchData: LineTouchData(
                                            touchTooltipData:
                                                LineTouchTooltipData(
                                              getTooltipColor: (touchedSpot) =>
                                                  Colors.black.withOpacity(0.8),
                                              getTooltipItems: (touchedSpots) {
                                                return touchedSpots.map(
                                                    (LineBarSpot touchedSpot) {
                                                  final date = DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          touchedSpot.x
                                                              .toInt());
                                                  return LineTooltipItem(
                                                    '${driverNames[selectedDriver]}\n'
                                                    '${DateFormat('HH:mm:ss').format(date)}\n'
                                                    'Posición: ${(21 - touchedSpot.y).toInt()}',
                                                    const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }).toList();
                                              },
                                            ),
                                          ),
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: true,
                                            horizontalInterval: 1,
                                            verticalInterval: 3600000, // 1 hora
                                          ),
                                          titlesData: FlTitlesData(
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  final date = DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          value.toInt());
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Text(
                                                      DateFormat('HH:mm')
                                                          .format(date),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                interval: 3600000, // 1 hora
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  int invertedValue =
                                                      21 - value.toInt();
                                                  return Text(
                                                    invertedValue.toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  );
                                                },
                                                interval: 1,
                                                reservedSize: 20,
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                          ),
                                          borderData: FlBorderData(show: true),
                                          minY: 1,
                                          maxY: 20,
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: getDriverSpots(
                                                  selectedDriver!),
                                              isCurved: false,
                                              color:
                                                  driverColors[selectedDriver],
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter: (spot, percent,
                                                    barData, index) {
                                                  return FlDotCirclePainter(
                                                    radius: 4,
                                                    color: driverColors[
                                                            selectedDriver] ??
                                                        Colors.blue,
                                                    strokeWidth: 1,
                                                    strokeColor: Colors.white,
                                                  );
                                                },
                                              ),
                                              belowBarData:
                                                  BarAreaData(show: false),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Piloto: ${driverNames[selectedDriver]}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Número: #$selectedDriver',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Mejor posición: ${getBestPositionText(selectedDriver!)}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            getFinalPosition(selectedDriver!) ==
                                                    0
                                                ? 'No hay información'
                                                : getFinalPosition(
                                                            selectedDriver!) ==
                                                        1
                                                    ? 'Resultado final: ${getFinalPosition(selectedDriver!)}° 🏆'
                                                    : 'Resultado final: ${getFinalPosition(selectedDriver!)}°',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
              Row(
                children: [
                  Text(
                    'Clima',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    child: Container(
                      color: Colors.white,
                      height: 1.5,
                    ),
                    fit: FlexFit.tight,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Icon(Icons.cloud)
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: sessionsProvider.isLoadingWeather
                    ? Container(
                        padding: EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: LoadingAnimationWidget.inkDrop(
                          size: 40,
                          color: Color.fromARGB(255, 56, 56, 63),
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14, height: 1.3),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Temperatura del aire: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '$airTemperature °C\n',
                            ),
                            TextSpan(
                              text: 'Humedad: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '$humidity%\n',
                            ),
                            TextSpan(
                              text: 'Presión: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '$pressure hPa\n',
                            ),
                            TextSpan(
                              text: 'Precipitación: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '$rainfall mm\n',
                            ),
                            TextSpan(
                              text: 'Temperatura de la pista: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '$trackTemperature °C\n',
                            ),
                            TextSpan(
                              text: 'Dirección del viento: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '$windDirection°\n',
                            ),
                            TextSpan(
                              text: 'Velocidad del viento: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '$windSpeed m/s\n',
                            )
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
