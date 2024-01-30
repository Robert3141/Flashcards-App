import 'dart:async';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/UI/UIHome.dart';
import 'package:flashcards/UI/UIEditCards.dart';
import 'package:flashcards/globals.dart' as globals;


//run the app
Future main() async {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class AppThemes {
  static const int LightTheme = 0;
  static const int DarkTheme = 1;
}
final themeCollection = ThemeCollection(
  themes: {
    AppThemes.LightTheme: ThemeData(
        primarySwatch: globals.defaultThemeColor,
        brightness: Brightness.light
    ),
    AppThemes.DarkTheme: ThemeData(
        primarySwatch: globals.defaultThemeColor,
        brightness: Brightness.dark
    )
  },
);

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      EditCards.routeName: (BuildContext context) =>
          new EditCards(currentFileData: ['1', '2'], currentFileNo: 0),
    };

    return new DynamicTheme(
      builder: (BuildContext context, ThemeData themeData) {
        return new MaterialApp(
          title: globals.appName,
          theme: themeData,
          darkTheme: new ThemeData(
            primarySwatch: globals.defaultThemeColor,
            brightness: Brightness.dark,
          ),
          home: new MyHomePage(
            title: globals.appName,
          ),
          routes: routes,
        );
      },
      themeCollection: themeCollection,
    );
  }
}
