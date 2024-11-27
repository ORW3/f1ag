import 'package:f1ag/main.dart';
import 'package:f1ag/providers/drivers_provider.dart';
import 'package:f1ag/providers/pages_provider.dart';
import 'package:f1ag/providers/sessions_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  @override
  Widget build(BuildContext context) {
    final sessionsProvider = Provider.of<SessionsProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        mainPageKey.currentState?.navigateToPage(0);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 40),
          itemCount: sessionsProvider.sessionsMeetingKey.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 35,
                  ),
                  Text(
                    sessionsProvider.meetingOfficialName,
                    style: TextStyle(fontSize: 14, fontFamily: 'f1-bold'),
                  )
                ],
              );
            } else {
              final session = sessionsProvider.sessionsMeetingKey[index - 1];
              final sessionName = session['session_name'] ?? 'Unknown';
              final location = session['location'] ?? 'Unknown';
              final dateStart = session['date_start'] ?? 'Unknown';
              final dateEnd = session['date_end'] ?? 'Unknown';

              DateTime dateStartFecha =
                  DateTime.parse(dateStart).toUtc().add(Duration(hours: -6));
              DateTime dateEndFecha =
                  DateTime.parse(dateEnd).toUtc().add(Duration(hours: -6));

              String dateStartFormateada =
                  DateFormat("d 'de' MMMM 'de' y").format(dateStartFecha);

              dateStartFormateada = dateStartFormateada
                  .replaceAll("January", "enero")
                  .replaceAll("February", "febrero")
                  .replaceAll("March", "marzo")
                  .replaceAll("April", "abril")
                  .replaceAll("May", "mayo")
                  .replaceAll("June", "junio")
                  .replaceAll("July", "julio")
                  .replaceAll("August", "agosto")
                  .replaceAll("September", "septiembre")
                  .replaceAll("October", "octubre")
                  .replaceAll("November", "noviembre")
                  .replaceAll("December", "diciembre");

              String horaStartFormateada =
                  DateFormat.jm().format(dateStartFecha);

              horaStartFormateada = horaStartFormateada
                  .replaceAll("AM", "a. m.")
                  .replaceAll("PM", "p. m.");

              String dateEndFormateada =
                  DateFormat("d 'de' MMMM 'de' y").format(dateEndFecha);

              dateEndFormateada = dateEndFormateada
                  .replaceAll("January", "enero")
                  .replaceAll("February", "febrero")
                  .replaceAll("March", "marzo")
                  .replaceAll("April", "abril")
                  .replaceAll("May", "mayo")
                  .replaceAll("June", "junio")
                  .replaceAll("July", "julio")
                  .replaceAll("August", "agosto")
                  .replaceAll("September", "septiembre")
                  .replaceAll("October", "octubre")
                  .replaceAll("November", "noviembre")
                  .replaceAll("December", "diciembre");

              String horaEndFormateada = DateFormat.jm().format(dateEndFecha);

              horaEndFormateada = horaEndFormateada
                  .replaceAll("AM", "a. m.")
                  .replaceAll("PM", "p. m.");

              return GestureDetector(
                onTap: () {
                  Provider.of<DriversProvider>(context, listen: false)
                      .loadPositionsBySessionKey(session['session_key']);
                  Provider.of<SessionsProvider>(context, listen: false)
                      .getWeatherBySessionKey(session['session_key']);
                  Provider.of<PagesProvider>(context, listen: false)
                      .changeIsAgendaTap(false);

                  mainPageKey.currentState?.navigateToPage(6);
                },
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  margin: EdgeInsets.only(top: 35, left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 56, 56, 63),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: double.infinity,
                  /** Después */
                  child: Stack(
                    children: [
                      Positioned(
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          size: 30,
                          color: Color.fromARGB(146, 255, 255, 255),
                        ),
                        right: 10,
                        bottom: 20,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 30, right: 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 40,
                                ),
                                Text(
                                  sessionName
                                      .replaceAll('Race', 'Carrera Principal')
                                      .replaceAll('Practice', 'Libres')
                                      .replaceAll(
                                          'Sprint Qualifying', 'Clasificación')
                                      .replaceAll(
                                          'Qualifying', 'Clasificación'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
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
                                  height: 2,
                                ),
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    "$location - Inicio: $dateStartFormateada - $horaStartFormateada - Final: $dateEndFormateada - $horaEndFormateada",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
