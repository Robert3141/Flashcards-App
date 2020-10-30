import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashcards/UI/UIHome.dart';
import 'package:flashcards/UI/UIEditCards.dart';
import 'package:flashcards/globals.dart' as globals;
import 'package:dynamic_theme/dynamic_theme.dart';

import 'UI/UIEditCards.dart';

//run the app
Future main() async {
  runApp(new MyApp());
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
          new EditCards(currentFileData: ['1', '2'], currentFileNo: 0),
    };

    return new DynamicTheme(
      defaultBrightness: globals.defaultBrightness,
      data: (brightness) => new ThemeData(
        primarySwatch: globals.defaultThemeColor,
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return new MaterialApp(
          title: globals.appName,
          theme: theme,
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
    );
  }
}
