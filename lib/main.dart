import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flashcards/UI/UIHome.dart';
import 'package:flashcards/UI/UIEditCards.dart';
import 'package:flashcards/globals.dart' as globals;
import 'package:flutter_dynamic_theme/flutter_dynamic_theme.dart';

import 'globals.dart';


//run the app
Future main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      EditCards.routeName: (BuildContext context) =>
          const EditCards(
              currentFileData: ['1', '2'],
              currentFileNo: 0,
          ),
    };

    return FlutterDynamicTheme(
      themedWidgetBuilder: (BuildContext context, ThemeData themeData) {
        return MaterialApp(
          title: globals.appName,
          theme: themeData,
          darkTheme: ThemeData(
            primarySwatch: globals.defaultThemeColor,
            brightness: Brightness.dark,
          ),
          home: const MyHomePage(
            title: globals.appName,
          ),
          routes: routes,
        );
      },
      data: (Brightness brightness) => ThemeData(
        primarySwatch: defaultThemeColor,
        brightness: brightness,
      ),
    );
  }
}
