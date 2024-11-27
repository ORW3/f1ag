import 'package:f1ag/main.dart';
import 'package:f1ag/providers/drivers_provider.dart';
import 'package:f1ag/providers/meetings_provider.dart';
import 'package:f1ag/providers/pages_provider.dart';
import 'package:f1ag/providers/sessions_provider.dart';
import 'package:flutter/material.dart';
import 'package:f1ag/widgets/meta_bandera_painter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime fechaMostradaCalendario = DateTime.now();

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SessionsProvider>(context, listen: false).loadSessions();
      Provider.of<DriversProvider>(context, listen: false).loadDrivers();
      Provider.of<MeetingsProvider>(context, listen: false).loadMeetings();
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return Provider.of<SessionsProvider>(context, listen: false).events[day] ??
        [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      // Abrir el diálogo solo cuando el día cambia
      _showEventsDialog(selectedDay);
    } else {
      // Si es el mismo día, abrir el diálogo directamente con un pequeño retraso
      Future.delayed(Duration(milliseconds: 50), () {
        _showEventsDialog(selectedDay);
      });
    }
  }

  Color _getMarkerColor(String sessionType) {
    switch (sessionType) {
      case 'Race':
        return Colors.red;
      case 'Qualifying':
        return Colors.blue;
      case 'Practice':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  void _showCerrarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF15151E),
          title: Text(
            'Salir',
            style: TextStyle(fontFamily: 'f1-bold', fontSize: 14),
          ),
          content: Container(
            color: Color(0xFFF15151E),
            width: double.infinity,
            height: 60,
            child: ListTile(
              title: Text(
                '¿Está seguro que quiere salir de la aplicación?',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text(
                'Sí',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEventsDialog(DateTime selectedDay) {
    final events = _getEventsForDay(selectedDay);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF15151E),
          title: Text('Eventos',
              style: TextStyle(fontFamily: 'f1-bold', fontSize: 14)),
          content: Container(
            color: Color(0xFFF15151E),
            width: double.infinity,
            height: 150,
            child: events.length > 0
                ? ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      DateTime fecha = DateTime.parse(events[index].dateStart)
                          .toUtc()
                          .add(Duration(hours: -6));
                      String horaFormateada = DateFormat.jm().format(fecha);
                      horaFormateada = horaFormateada
                          .replaceAll("AM", "a. m.")
                          .replaceAll("PM", "p. m.");

                      return ListTile(
                        title: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(255, 56, 56, 63)),
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Text(
                                "${events[index].toString().replaceAll('Race', 'Carrera').replaceAll('Practice', 'Libres').replaceAll('Sprint Qualifying', 'Clasificación').replaceAll('Qualifying', 'Clasificación')}: ${horaFormateada}",
                                style: TextStyle(fontSize: 12),
                              ),
                              Spacer(),
                              Icon(
                                Icons.flag,
                                color: _getMarkerColor(
                                    events[index].sessionType.toString()),
                              )
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();

                          Provider.of<DriversProvider>(context, listen: false)
                              .loadPositionsBySessionKey(
                                  events[index].sessionKey);
                          Provider.of<SessionsProvider>(context, listen: false)
                              .getWeatherBySessionKey(events[index].sessionKey);
                          Provider.of<PagesProvider>(context, listen: false)
                              .changeIsAgendaTap(true);
                          mainPageKey.currentState?.navigateToPage(6);
                        },
                      );
                    },
                  )
                : ListTile(
                    title: Text('No hay eventos disponibles :('),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Event> _getEventsForMonth(DateTime month, String sessionType) {
    final events = Provider.of<SessionsProvider>(context, listen: false).events;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = (month.month == 12)
        ? DateTime(month.year, month.month, 31)
        : DateTime(month.year, month.month + 1, 1).subtract(Duration(days: 1));

    return events.entries
        .where((entry) =>
            entry.key.isAfter(startOfMonth) &&
            entry.key.isBefore(
                endOfMonth.add(Duration(days: 1))) && // Incluir el último día
            entry.value.any((event) => event.sessionType == sessionType))
        .expand((entry) => entry.value)
        .where((event) => event.sessionType == sessionType)
        .toList();
  }

  void _showEventsDialogForMonth(List<Event> events) {
    final meses = {
      1: "enero",
      2: "febrero",
      3: "marzo",
      4: "abril",
      5: "mayo",
      6: "junio",
      7: "julio",
      8: "agosto",
      9: "septiembre",
      10: "octubre",
      11: "noviembre",
      12: "diciembre"
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF15151E),
          title: Text('Eventos de ${meses[fechaMostradaCalendario.month]}',
              style: TextStyle(fontFamily: 'f1-bold', fontSize: 14)),
          content: Container(
            color: Color(0xFFF15151E),
            width: double.infinity,
            height: 200,
            child: events.isNotEmpty
                ? ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      DateTime fecha = DateTime.parse(events[index].dateStart)
                          .toUtc()
                          .add(Duration(hours: -6));
                      String horaFormateada = DateFormat.jm().format(fecha);
                      horaFormateada = horaFormateada
                          .replaceAll("AM", "a. m.")
                          .replaceAll("PM", "p. m.");

                      return ListTile(
                        title: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(255, 56, 56, 63),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Text(
                                "${events[index].toString().replaceAll('Race', 'Carrera').replaceAll('Practice', 'Libres').replaceAll('Sprint Qualifying', 'Clasificación').replaceAll('Qualifying', 'Clasificación')}: $horaFormateada",
                                style: TextStyle(fontSize: 12),
                              ),
                              Spacer(),
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100)),
                                alignment: Alignment.center,
                                child: Text(
                                  DateTime.parse(events[index].dateStart)
                                      .day
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: _getMarkerColor(
                                                  events[index].sessionType) ==
                                              Colors.white
                                          ? Colors.black
                                          : _getMarkerColor(events[index]
                                              .sessionType
                                              .toString())),
                                ),
                              ),
                              /*Spacer(),
                              Icon(
                                Icons.flag,
                                color: _getMarkerColor(
                                    events[index].sessionType.toString()),
                              ),*/
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Provider.of<DriversProvider>(context, listen: false)
                              .loadPositionsBySessionKey(
                                  events[index].sessionKey);
                          Provider.of<SessionsProvider>(context, listen: false)
                              .getWeatherBySessionKey(events[index].sessionKey);
                          Provider.of<PagesProvider>(context, listen: false)
                              .changeIsAgendaTap(true);
                          mainPageKey.currentState?.navigateToPage(6);
                        },
                      );
                    },
                  )
                : ListTile(
                    title: Text('No hay eventos disponibles :('),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cerrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        _showCerrarDialog();
      },
      child: Stack(
        children: [
          Positioned(
            left: 50,
            bottom: 0,
            child: Opacity(
              opacity: 1,
              child: Image.asset("assets/img/carshadow.png", scale: 5),
            ),
          ),
          Positioned(
            left: 150,
            bottom: 0,
            child: Opacity(
              opacity: 0.50,
              child: Image.asset("assets/img/carshadow.png", scale: 3.5),
            ),
          ),
          Positioned(
            left: 250,
            bottom: 0,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset("assets/img/carshadow.png", scale: 2),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 35,
                ),
                const Text(
                  'Agenda',
                  style: TextStyle(fontSize: 23, fontFamily: 'f1-bold'),
                ),
                const SizedBox(
                  height: 45,
                ),
                Container(
                  clipBehavior: Clip.hardEdge, //analogo de overflow hidden
                  child: Column(
                    children: [
                      Provider.of<SessionsProvider>(context).isLoading
                          ? Padding(
                              padding: EdgeInsets.all(50),
                              child: LoadingAnimationWidget.inkDrop(
                                size: 40,
                                color: Color.fromARGB(255, 56, 56, 63),
                              ),
                            )
                          : TableCalendar(
                              locale: 'es_MX',
                              availableCalendarFormats: const {
                                CalendarFormat.month: 'Mensual',
                                CalendarFormat.twoWeeks: '2 semanas',
                                CalendarFormat.week: 'Semanal',
                              },
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              headerStyle: HeaderStyle(
                                formatButtonTextStyle: TextStyle(
                                    color: Colors.black, fontSize: 11),
                                titleTextStyle: TextStyle(fontSize: 12),
                                formatButtonDecoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              calendarStyle: CalendarStyle(
                                markersAutoAligned: true,
                                markerDecoration: BoxDecoration(
                                    color: Color(0xFFE10600),
                                    borderRadius: BorderRadius.circular(100)),
                                outsideTextStyle: TextStyle(
                                    color: Color.fromARGB(156, 244, 67, 54)),
                                todayDecoration: BoxDecoration(
                                  color: Color(0xFFE10600),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              onPageChanged: (focusedDay) {
                                fechaMostradaCalendario = focusedDay;
                              },
                              calendarFormat: _calendarFormat,
                              firstDay: DateTime.utc(2010, 10, 16),
                              lastDay: DateTime.utc(2030, 3, 14),
                              focusedDay: _focusedDay,
                              onDaySelected: _onDaySelected,
                              eventLoader: (day) {
                                return _getEventsForDay(day);
                              },
                              calendarBuilders: CalendarBuilders(
                                markerBuilder: (context, date, events) {
                                  if (events.isNotEmpty) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: events.take(3).map((event) {
                                        final eventObj = event as Event;

                                        return Icon(
                                          Icons.flag,
                                          color: _getMarkerColor(
                                              eventObj.sessionType),
                                          size: 12,
                                        );
                                        /*return Container(
                                    width: 7,
                                    height: 7,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1.5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: _getMarkerColor(
                                              eventObj.sessionType)),
                                      color: Colors.black,
                                      shape: BoxShape.rectangle,
                                    ),
                                  );*/
                                      }).toList(),
                                    );
                                  }
                                  return null;
                                },
                              ),
                              onFormatChanged: (format) {
                                setState(
                                  () {
                                    _calendarFormat = format;
                                  },
                                );
                              },
                            ),
                      SizedBox(
                        height: 5,
                      ),
                      if (Provider.of<SessionsProvider>(context).isLoading ==
                          false)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                final practiceEvents = _getEventsForMonth(
                                    fechaMostradaCalendario, 'Practice');
                                _showEventsDialogForMonth(practiceEvents);
                              },
                              label: Text(
                                'Libres',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
                              ),
                              icon: Icon(
                                Icons.flag,
                                color: Colors.white,
                                size: 12,
                              ),
                              style: ButtonStyle(
                                  padding: WidgetStatePropertyAll(
                                      EdgeInsets.all(0))),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final qualifyingEvents = _getEventsForMonth(
                                    fechaMostradaCalendario, 'Qualifying');
                                _showEventsDialogForMonth(qualifyingEvents);
                              },
                              label: Text(
                                'Clasificación',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
                              ),
                              icon: Icon(
                                Icons.flag,
                                color: Colors.blue,
                                size: 12,
                              ),
                              style: ButtonStyle(
                                  padding: WidgetStatePropertyAll(
                                      EdgeInsets.all(0))),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final raceEvents = _getEventsForMonth(
                                    fechaMostradaCalendario, 'Race');
                                _showEventsDialogForMonth(raceEvents);
                              },
                              label: Text(
                                'Carrera',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white),
                              ),
                              icon: Icon(
                                Icons.flag,
                                color: Colors.red,
                                size: 12,
                              ),
                              style: ButtonStyle(
                                  padding: WidgetStatePropertyAll(
                                      EdgeInsets.all(0))),
                            ),
                          ],
                        ),
                      SizedBox(
                        height: 5,
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
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.black),
                ),
                //Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;
  final String sessionType;
  final int sessionKey;
  final String dateStart;

  const Event(this.title, this.sessionType, this.sessionKey, this.dateStart);

  @override
  String toString() => title;
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
