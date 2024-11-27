import 'package:f1ag/main.dart';
import 'package:f1ag/providers/meetings_provider.dart';
import 'package:f1ag/providers/sessions_provider.dart';
import 'package:flutter/material.dart';
import 'package:f1ag/widgets/meta_bandera_painter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MeetingsProvider>(context, listen: false).loadMeetings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final meetingsProvider = Provider.of<MeetingsProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        mainPageKey.currentState?.navigateToPage(1);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: meetingsProvider.isLoading
            ? LoadingAnimationWidget.inkDrop(
                size: 40,
                color: Color.fromARGB(255, 56, 56, 63),
              )
            : ListView.builder(
                padding: EdgeInsets.only(bottom: 40),
                itemCount: meetingsProvider.meetings.length + 1,
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
                          'Meetings ${DateTime.now().year}',
                          style: TextStyle(fontSize: 23, fontFamily: 'f1-bold'),
                        )
                      ],
                    );
                  } else {
                    final meeting = meetingsProvider.meetings[index - 1];
                    final officialName =
                        meeting['meeting_official_name'] ?? 'Unknown';
                    final location = meeting['location'] ?? 'Unknown';
                    final dateStart = meeting['date_start'] ?? 'Unknown';
                    final meetingKey = meeting['meeting_key'] ?? 0;
                    DateTime fecha = DateTime.parse(dateStart);
                    DateTime hora = DateTime.parse(dateStart)
                        .toUtc()
                        .add(Duration(hours: -6));

                    // Formatear la fecha a "29 de febrero de 2024"
                    String fechaFormateada =
                        DateFormat("d 'de' MMMM 'de' y").format(fecha);

                    fechaFormateada = fechaFormateada
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

                    String horaFormateada = DateFormat.jm().format(hora);

                    horaFormateada = horaFormateada
                        .replaceAll("AM", "a. m.")
                        .replaceAll("PM", "p. m.");

                    return GestureDetector(
                      onTap: () {
                        Provider.of<SessionsProvider>(context, listen: false)
                            .getSessions(meetingKey, officialName);
                        mainPageKey.currentState?.navigateToPage(5);
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        margin: EdgeInsets.only(top: 35, left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 56, 56, 63),
                            borderRadius: BorderRadius.circular(20)),
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
                              bottom: 30,
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 30, right: 30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom:
                                                BorderSide(color: Colors.white),
                                          ),
                                        ),
                                        child: Text(
                                          officialName,
                                          style: TextStyle(
                                            fontFamily: 'f1-bold',
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "$location - Inicio: $fechaFormateada, $horaFormateada",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 50,
                                      ),
                                    ],
                                  ),
                                ),
                                CustomPaint(
                                  painter: MetaBanderaPainter(),
                                  child: Container(
                                    height: 10,
                                    width: double.infinity,
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
