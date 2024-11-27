import 'package:f1ag/main.dart';
import 'package:flutter/material.dart';
import 'package:f1ag/providers/drivers_provider.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriversProvider>(context, listen: false).loadDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final driversProvider = Provider.of<DriversProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        mainPageKey.currentState?.navigateToPage(1);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: driversProvider.isLoading
            ? LoadingAnimationWidget.inkDrop(
                size: 40,
                color: Color.fromARGB(255, 56, 56, 63),
              )
            : ListView.builder(
                padding: EdgeInsets.only(bottom: 40),
                itemCount: driversProvider.drivers.length,
                itemBuilder: (context, index) {
                  final driver = driversProvider.drivers[index];
                  final fullName = driver['full_name'] ?? 'Unknown';
                  final teamName = driver['team_name'] ?? 'No team';
                  final driverNumber =
                      driver['driver_number']?.toString() ?? 'N/A';
                  final headshotUrl = driver['headshot_url'] ?? '';
                  final cleanedHeadshotUrl =
                      headshotUrl.replaceAll(".transform/1col/image.png", "");

                  return GestureDetector(
                    onTap: () {
                      mainPageKey.currentState?.navigateToPage(3);
                      driversProvider.setIndex(index);
                    },
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      margin: EdgeInsets.only(top: 35, left: 10, right: 10),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 56, 56, 63),
                          borderRadius: BorderRadius.circular(20)),
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned(
                            child: Image.network(
                              cleanedHeadshotUrl,
                              scale: 5.3,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Image.asset(
                                  'assets/img/profile2.png',
                                  scale: 5.3,
                                  color: Color.fromARGB(128, 0, 0, 0),
                                );
                              },
                            ),
                            bottom: 0,
                            right: -20,
                          ),
                          Positioned(
                            bottom: -20,
                            right: 5,
                            child: Opacity(
                              opacity: .55,
                              child: Text(
                                textAlign: TextAlign.end,
                                driverNumber,
                                style: TextStyle(
                                    leadingDistribution:
                                        TextLeadingDistribution.proportional,
                                    fontSize: 60,
                                    color: Colors.white,
                                    fontFamily: 'Open Sans',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30, right: 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 50),
                                Container(
                                  padding: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  child: Text(
                                    fullName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.7,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(teamName),
                                SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
