import 'dart:ui';
import 'package:f1ag/pages/car_page.dart';
import 'package:f1ag/pages/driver_page.dart';
import 'package:f1ag/pages/posiciones_page.dart';
import 'package:f1ag/providers/meetings_provider.dart';
import 'package:f1ag/providers/pages_provider.dart';
import 'package:f1ag/providers/sessions_provider.dart';
import 'package:f1ag/services/team_service.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:f1ag/pages/agenda_page.dart';
import 'package:f1ag/pages/drivers_page.dart';
import 'package:f1ag/pages/meetings_page.dart';
import 'package:f1ag/pages/meeting_page.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:f1ag/providers/drivers_provider.dart';
import 'package:f1ag/providers/drivers_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DriversProvider()),
        ChangeNotifierProvider(create: (_) => SessionsProvider()),
        ChangeNotifierProvider(create: (_) => MeetingsProvider()),
        ChangeNotifierProvider(create: (_) => PagesProvider()),
        ChangeNotifierProvider(create: (context) => TeamService())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color(0xFFF15151E),
          ),
          fontFamily: 'Open Sans',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color(0xFFF15151E),
          appBarTheme: AppBarTheme(
            color: Color(0xFFF15151E),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('es', 'MX'),
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            secondary: Color(0xFFE10600),
            seedColor: Color(0xFFE10600),
          ),
          useMaterial3: true,
        ),
        home: _Splash() //MyHomePage(key: mainPageKey, title: 'F1AG'),
        );
  }
}

final GlobalKey<_MyHomePageState> mainPageKey = GlobalKey<_MyHomePageState>();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  final iconList = <IconData>[
    Icons.flag,
    Icons.calendar_month,
    Icons.person_rounded,
  ];
  final PageController _pageController = PageController(initialPage: 1);

  void navigateToPage(int index) {
    _pageController.jumpToPage(
      index,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Provider.of<PagesProvider>(context, listen: false)
          .changeIsAgendaTap(false);
    });

    _pageController.jumpToPage(
      index,
    );
    /*_pageController.animateToPage(index,
        duration: Duration(milliseconds: 600),
        curve: Curves.fastLinearToSlowEaseIn);*/
  }

  // Lista de pantallas
  static List<Widget> _pages = <Widget>[
    MeetingsPage(),
    AgendaPage(),
    DriversPage(),
    DriverPage(),
    CarPage(),
    MeetingPage(),
    PosicionesPage()
  ];

  static List<String> _text = <String>[
    "Meetings",
    "Agenda",
    "Pilotos",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: CustomPageViewScrollPhysics(),
        onPageChanged: (index) {
          if (index < 3) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE10600), width: 2),
          ),
        ),
        child: AnimatedBottomNavigationBar.builder(
          itemCount: iconList.length,
          splashSpeedInMilliseconds: 0,
          tabBuilder: (index, isActive) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconList[index],
                  size: 24,
                  color: isActive ? Colors.white : Color(0xFF747C92),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  _text[index],
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? Colors.white : Color(0xFF747C92),
                  ),
                ),
              ],
            );
          },
          gapWidth: 0,
          activeIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          height: 65,
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        title: Image.asset(
          'assets/img/logoag.png',
          width: 180,
        ),
        centerTitle: true,
      ),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash({super.key});

  @override
  State<_Splash> createState() => __SplashState();
}

class __SplashState extends State<_Splash> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    new Future.delayed(
        const Duration(seconds: 5),
        () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MyHomePage(key: mainPageKey, title: 'F1AG')),
            ));

    _controller = VideoPlayerController.asset('assets/video/e.mp4')
      ..initialize().then((_) {
        // Once the video has been loaded we play the video and set looping to true.
        _controller.play();

        _controller.setLooping(false);
        _controller.setVolume(1);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: SizedBox.expand(
          child: FittedBox(
            // If your background video doesn't look right, try changing the BoxFit property.
            // BoxFit.fill created the look I was going for.
            fit: BoxFit.contain,
            child: SizedBox(
              width: _controller.value.size?.width ?? 0,
              height: _controller.value.size?.height ?? 0,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
      ),
    );
  }
}

// Crear una nueva clase para la física personalizada
class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // Solo permitir scroll si la posición actual es menor a 1
    return position.pixels < (position.viewportDimension * 1);
  }
}
