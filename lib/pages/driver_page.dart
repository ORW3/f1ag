import 'dart:convert';

import 'package:f1ag/main.dart';
import 'package:f1ag/models/team.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:f1ag/providers/drivers_provider.dart';
import 'package:provider/provider.dart';
import 'package:f1ag/services/team_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_flags/country_flags.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DriverPage extends StatelessWidget {
  const DriverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final driversProvider = Provider.of<DriversProvider>(context);
    Map<String, dynamic> driver = {};

    Map<String, String> toAlpha2 = {
      'NED': 'NL', // Netherlands
      'GBR': 'GB', // United Kingdom
      'FRA': 'FR', // France
      'MEX': 'MX', // Mexico
      'ESP': 'ES', // Spain
      'MON': 'MC', // Monaco
      'CAN': 'CA', // Canada
      'JPN': 'JP', // Japan
      'THA': 'TH', // Thailand
      'CHN': 'CN', // China
      'GER': 'DE', // Germany
      'NZL': 'NZ', // New Zealand
      'ARG': 'AR', // Argentina
      'FIN': 'FI', // Finland
      'AUS': 'AU', // Australia
    };

    if (driversProvider.drivers.isNotEmpty)
      driver = driversProvider.drivers[driversProvider.indexDriver];

    final fullName = driver['full_name'] ?? 'Unknown';
    final teamName = driver['team_name'] ?? 'No team';
    final driverNumber = driver['driver_number']?.toString() ?? 'N/A';
    final headshotUrl = driver['headshot_url'] ?? '';
    final cleanedHeadshotUrl =
        headshotUrl.replaceAll(".transform/1col/image.png", "");
    final countryCode = driver["country_code"] ?? 'NON';
    final teamColor = driver["team_colour"] ?? 'FFFFFF';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        mainPageKey.currentState?.navigateToPage(2);
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 40, right: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: CachedNetworkImage(
                    imageUrl: cleanedHeadshotUrl,
                    width: 200,
                    color: Color(int.parse("0xFF$teamColor")).withOpacity(0.15),
                    placeholder: (context, url) => Image.asset(
                      'assets/img/profile.png', // Imagen de respaldo
                      width: 200,
                      color:
                          Color(int.parse("0xFF$teamColor")).withOpacity(0.15),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/img/profile.png', // Imagen de respaldo
                      width: 200,
                      color:
                          Color(int.parse("0xFF$teamColor")).withOpacity(0.15),
                    ),
                  ),
                  /*Image.network(
                  cleanedHeadshotUrl,
                  width: 200,
                  color: Color(int.parse("0xFF$teamColor")).withOpacity(0.15),
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/img/profile.png', // Imagen de respaldo
                      width: 200,
                      color:
                          Color(int.parse("0xFF$teamColor")).withOpacity(0.15),
                    );
                  },
                ),*/
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10.0,
                    sigmaY: 10.0,
                  ),
                  child: /*Image.network(
                  cleanedHeadshotUrl,
                  width: 200,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/img/profile.png', // Imagen de respaldo
                      width: 200,
                      color: Colors.white,
                    );
                  },
                ),*/
                      CachedNetworkImage(
                    imageUrl: cleanedHeadshotUrl,
                    width: 200,
                    placeholder: (context, url) => Image.asset(
                      'assets/img/profile.png', // Imagen de respaldo
                      width: 200,
                      color: Colors.white,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/img/profile.png', // Imagen de respaldo
                      width: 200,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              clipBehavior: Clip.hardEdge,
              margin: EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: 20,
                    child: Opacity(
                      opacity: .28,
                      child: Text(
                        textAlign: TextAlign.end,
                        driverNumber,
                        style: TextStyle(
                            letterSpacing: -1,
                            height: 0.8,
                            fontSize: 90,
                            fontFamily: 'f1-bold',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      height: 40,
                      width: 300,
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            offset: Offset(10, 10),
                            color: Colors.black,
                            blurRadius: 25)
                      ]),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFFFFFFF)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var word in fullName.split(' '))
                                    Text(
                                      word,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      mainPageKey.currentState
                                          ?.navigateToPage(4);
                                    },
                                    style: ButtonStyle(
                                      iconColor: WidgetStatePropertyAll(
                                          Color(int.parse("0xFF$teamColor"))),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // ajusta el tamaño de la columna
                                      children: [
                                        ImageIcon(
                                          AssetImage(
                                              'assets/img/carshadow.png'),
                                        ),
                                        SizedBox(
                                            height:
                                                1), // Espacio entre el icono y el texto
                                        Text(
                                          'Ver automóvil',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(
                                                  int.parse("0xFF$teamColor"))),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          '$teamName',
                          style: TextStyle(fontSize: 13),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FutureBuilder<Team?>(
                          future:
                              Provider.of<TeamService>(context, listen: false)
                                  .obtenerTeamPorNombre(teamName),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: LoadingAnimationWidget.inkDrop(
                                  size: 40,
                                  color: Color.fromARGB(255, 56, 56, 63),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error,
                                        color: Colors.red, size: 50),
                                    SizedBox(height: 8),
                                    Text(
                                      'Error al cargar el equipo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data != null) {
                              final team = snapshot.data!;
                              return Center(
                                child: ColoredBox(
                                  color: Color.fromARGB(0, 255, 255, 255),
                                  child: Stack(
                                    children: [
                                      ImageFiltered(
                                        imageFilter: ImageFilter.dilate(
                                            radiusX: 2, radiusY: 2),
                                        child: Image.network(
                                          color: Colors.white,
                                          team.team_logo2,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                            return Image.asset(
                                              'assets/img/team.jpg',
                                              width: 200,
                                              color: Colors.white,
                                            );
                                          },
                                        ),
                                      ),
                                      Image.network(
                                        team.team_logo2,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Image.asset(
                                            'assets/img/team.jpg',
                                            width: 200,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                child: Text(
                                  'No se encontró el equipo',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4)),
                              padding: EdgeInsets.only(
                                  bottom: 4, top: 4, left: 12, right: 12),
                              child: Text(
                                countryCode,
                                style: TextStyle(
                                    color: Color(0xFFFE0000), fontSize: 11),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CountryFlag.fromCountryCode(
                              toAlpha2[countryCode] ?? countryCode,
                              width: 40,
                              height: 24,
                              shape: const RoundedRectangle(6),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 80,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
