import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:meetingzilla/constants/colors.dart';
import 'package:meetingzilla/constants/strings.dart';
import 'package:meetingzilla/pages/splash_page.dart';
import 'package:meetingzilla/providers/auth_provider.dart';
import 'package:meetingzilla/providers/channel_provider.dart';
import 'package:meetingzilla/utils/custom_route.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (SchedulerBinding.instance.window.platformBrightness ==
        Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: lightBackgroundColor,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: lightBackgroundColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: materialDarkColor,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: materialDarkColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChannelProvider()),
      ],
      child: MaterialApp(
        title: APP_NAME,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: lightBackgroundColor,
          primarySwatch: materialAccentColor,
          accentColor: accentColor,
          bottomAppBarColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
          }),
        ),
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: materialDarkColor,
          bottomAppBarColor: darkBottomBarColor,
          bottomSheetTheme:
              BottomSheetThemeData(backgroundColor: darkBottomBarColor),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
          }),
        ),
        home: SplashPage(),
      ),
    );
  }
}
