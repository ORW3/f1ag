import 'package:cached_network_image/cached_network_image.dart';
import 'package:f1ag/main.dart';
import 'package:f1ag/models/team.dart';
import 'package:f1ag/providers/drivers_provider.dart';
import 'package:f1ag/providers/pages_provider.dart';
import 'package:flutter/material.dart';
import 'package:f1ag/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:f1ag/services/team_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CarPage extends StatefulWidget {
  const CarPage({super.key});

  @override
  State<CarPage> createState() => _CarPageState();
}

class _CarPageState extends State<CarPage> {
  //Map<String, dynamic> _carFuture = {};
  dynamic _carFuture = {};
  final ApiService apiService = ApiService();
  Map<String, dynamic> driver = {};
  bool isLoading = true;
  bool finish = false;

  @override
  void initState() {
    super.initState();
    _data();
  }

  Future<void> _data() async {
    if (!mounted) return;

    final driversProvider =
        Provider.of<DriversProvider>(context, listen: false);

    if (driversProvider.drivers.isNotEmpty) {
      driver = driversProvider.drivers[driversProvider.indexDriver];
    }

    try {
      _carFuture = await apiService.fetchLastCar(driver["driver_number"] ?? 0);
    } catch (e) {
      _carFuture =
          'Error: la información del automóvil no está disponible. Por favor, intenta nuevamente más tarde.';
      finish = true;
    }

    isLoading = false;
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = driver['full_name'] ?? 'Unknown';
    String number = "";
    String teamName = "";
    if (driver["driver_number"] != null) {
      number = driver["driver_number"].toString();
      teamName = driver['team_name'].toString();
    }
    String rpm = "N/A";
    String speed = "N/A"; //velocidad
    String nGear = "N/A"; //marcha engra
    String throttle = "N/A"; //potencia maxima del motor
    String drs = "N/A";
    String brake = "N/A"; //freno
    String date = DateTime.now().toString();

    if (!finish && !isLoading) {
      rpm = _carFuture["rpm"].toString() ?? "N/A";
      speed = _carFuture["speed"].toString() ?? "N/A"; //velocidad
      nGear = _carFuture["n_gear"].toString() ?? "N/A"; //marcha engra
      throttle = _carFuture["throttle"].toString() ??
          "N/A"; //potencia maxima del motor
      drs = _carFuture["drs"].toString() ?? "N/A";
      brake = _carFuture["brake"].toString() ?? "N/A"; //freno
      date = _carFuture["date"] ?? DateTime.now().toString(); //fecha
    }

    DateTime fecha = DateTime.parse(date);
    DateTime hora = DateTime.parse(date).toUtc().add(Duration(hours: -6));

    // Formatear la fecha a "29 de febrero de 2024"
    String fechaFormateada = DateFormat("d 'de' MMMM 'de' y").format(fecha);

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

    horaFormateada =
        horaFormateada.replaceAll("AM", "a. m.").replaceAll("PM", "p. m.");

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        mainPageKey.currentState?.navigateToPage(3);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 40, right: 40),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: Opacity(
                opacity: 0.37,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: [Colors.white, Color.fromARGB(255, 21, 21, 30)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  child: Text(
                    number,
                    style: const TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                        height: 0,
                        fontFamily: 'f1-bold',
                        letterSpacing: -3),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Stack(),
                const SizedBox(
                  height: 90,
                ),
                FutureBuilder<Team?>(
                  future: Provider.of<TeamService>(context, listen: false)
                      .obtenerTeamPorNombre(teamName),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final team = snapshot.data!;
                      return Stack(
                        children: [
                          Positioned(
                            left: -10,
                            top: -10,
                            child: Opacity(
                                opacity: 0.8,
                                child: CachedNetworkImage(
                                  imageUrl: team.car,
                                  scale: 2,
                                  color: Color(int.parse(
                                      "0xFF${driver['team_colour']}")),
                                )), /*Image.network(
                              'https://res.cloudinary.com/dogupuezd/image/upload/v1728886512/red-bull-racing_rjdmvf.png',
                              color: Colors.white,
                              scale: 2,
                            )),*/
                          ),
                          Image.network(
                            team.car,
                          ),
                        ],
                      );
                    } else {
                      return Stack(
                        children: [
                          Positioned(
                            left: -10,
                            top: -10,
                            child: Opacity(
                                opacity: 0.8,
                                child: Image.asset(
                                  'assets/img/car.png',
                                  color: Colors.white,
                                  scale: 2,
                                )),
                          ),
                          Image.asset(
                            'assets/img/car.png',
                            color: Colors.white,
                          ),
                        ],
                      );
                    }
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      child: Text(
                        fullName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    isLoading
                        ? Container(
                            margin:
                                EdgeInsets.only(top: 50, left: 20, right: 20),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                LoadingAnimationWidget.inkDrop(
                                  size: 40,
                                  color: Color.fromARGB(255, 56, 56, 63),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  'Ajustando los neumáticos... esto tomará solo un momento.',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 56, 56, 63),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ))
                        : finish
                            ? Column(
                                children: [
                                  Center(
                                    child: Text(_carFuture),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Color.fromARGB(255, 56, 56, 63))),
                                    onPressed: () async {
                                      setState(() {
                                        finish = false;
                                        isLoading = true;
                                      });
                                      try {
                                        _carFuture =
                                            await apiService.fetchLastCar(
                                                driver["driver_number"] ?? 0);
                                        setState(() {
                                          isLoading = false;
                                        });
                                      } catch (e) {
                                        _carFuture =
                                            'Error: la información del automóvil no está disponible. Por favor, intenta nuevamente más tarde.';
                                        finish = true;
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    },
                                    child: Text(
                                      'Reintentar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                              )
                            : RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 18, height: 1.3),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Freno: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$brake\n',
                                    ),
                                    TextSpan(
                                      text: 'Fecha: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$fechaFormateada\n',
                                    ),
                                    TextSpan(
                                      text: 'Hora: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$horaFormateada\n',
                                    ),
                                    TextSpan(
                                      text: 'DRS: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$drs\n',
                                    ),
                                    TextSpan(
                                      text: 'Marcha engranada: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$nGear\n',
                                    ),
                                    TextSpan(
                                      text: 'RPM: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$rpm\n',
                                    ),
                                    TextSpan(
                                      text: 'Velocidad: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$speed km/h\n',
                                    ),
                                    TextSpan(
                                      text: 'Posición del acelerador: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$throttle\n',
                                    )
                                  ],
                                ),
                              ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
