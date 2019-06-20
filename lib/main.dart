import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  runApp(new MyApp());
}

final cardHeight = 100.0;

class MyApp extends StatefulWidget {

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  bool darkThemeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flashcards',
      theme: new ThemeData(
        //app theme
        primarySwatch: Colors.blue,
        brightness: darkThemeEnabled?Brightness.dark:Brightness.light,
      ),
      home: new MyHomePage(
        title: 'Flashcards',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //set local variables
  int _currentTabIndex = 0;
  var _tabTitle = "Main";
  List<String> _flashcardFiles = ['example file'];
  List<String> _flashcardLengths = ['2'];
  final myController = TextEditingController();

  //functions
  void clickImportFlashcards() async {
    try {
      //local vars
      File file = await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'txt');
      String fileText = "test";//await file.readAsString();
      String fileName = file.path;//splitter(file.path, "/").last;
      int fileCards = /*splitter(fileText,"&").length*/4 ~/ 2;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> _flashcards = prefs.getStringList('flashcards') ?? [fileText];
      _flashcardFiles = prefs.getStringList('flashcardFiles') ?? [fileName];
      _flashcardLengths = prefs.getStringList('flashcardsLengths') ?? [fileCards.toString()];

      //add file to prefs
      if (_flashcards[0] != fileText){
        _flashcards.add(fileText);
      }
      await prefs.setStringList('flashcards',_flashcards);
      if (_flashcardFiles[0] != fileName){
        _flashcardFiles.add(fileName);
      }
      await prefs.setStringList('flashcardFiles',_flashcardFiles);
      if (_flashcardLengths[0] != fileCards.toString()) {
        _flashcardLengths.add('$fileCards');
      }
      await prefs.setStringList('flashcardLengths', _flashcardLengths);


    } catch(e) {
      print("Error: " + e.toString());
    }

    setState(() {

    });

  }



  void clickCreateFlashcards() {

  }

  void clickEditFlashcards(int fileNumber) {

  }

  void clickLoadFlashcards(int fileNumber) {

  }

  void loadFromPreferences() async {
    //variables
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //set variables
    _flashcardFiles = prefs.getStringList('flashcardFiles')?? ['example file'];
    _flashcardLengths = prefs.getStringList('flashcardLengths')?? ['2'];
  }

  List<String> splitter(String splitText,String splitChar) {
    //local variables
    List<String> _fileList;
    var tempString = "";

    for (var i = 0; i <splitText.length +1; i++) {
      if (splitText[i] == splitChar){
        if (tempString != ""){
          _fileList.add(tempString);
        }
        tempString = "";
      } else {
        tempString += splitText[i];
      }
    }

    if (tempString != ""){
      _fileList.add(tempString);
    }

    return _fileList;
  }


  @override
  Widget build(BuildContext context) {
    //build the page with the flashcards
    loadFromPreferences();
    final _tabPages = <Widget>[
      //Main Tab
      Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Card(
                  child: Container(
                    height: cardHeight,
                    child: InkWell(
                      splashColor: Theme.of(context).primaryColor,
                      onTap: (){
                        setState(() {
                          //Add Cards dialog
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => SimpleDialog(
                              title: Text('Add new Flashcards'),
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.folder_open),
                                  title: Text('Import Flashcards'),
                                  onTap: (){
                                    clickImportFlashcards();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.control_point),
                                  title: Text('Create Flashcards'),
                                  onTap: (){
                                    clickCreateFlashcards();
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("     Add new file!",overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.add),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: _flashcardFiles.length,
                    itemBuilder: (BuildContext context, int index){
                      return Card(
                          child: Container(
                            height: cardHeight,
                            child: InkWell(
                              splashColor: Theme.of(context).primaryColor,
                              onTap: (){
                                //open cards dialog
                                setState(() {
                                  //Add Cards dialog
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) => SimpleDialog(
                                      title: Text(_flashcardFiles[index]),
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text('Edit'),
                                          onTap: (){
                                            clickEditFlashcards(index);
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.content_copy),
                                          title: Text('Load Flashcards'),
                                          onTap: (){
                                            clickLoadFlashcards(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[

                                  Text('     '+_flashcardFiles[index],overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold)),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(_flashcardLengths[index]),
                                      Icon(Icons.content_copy),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      );
                    },
                  ),
                ),
              ],
          ),
      ),

      //Settings
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('Settings'),
            Divider(),
          ],
        )
      ),
    ];

    final _appBar = AppBar(
      title: Text(_tabTitle),
      centerTitle: true,
    );

    final bottomNavBar = BottomNavigationBar(
      currentIndex: _currentTabIndex,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.content_copy),
            title: Text('Flashcards'),

          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
      onTap: (int index){
          setState(() {
            _currentTabIndex = index;
            switch (index) {
              case 0:
                _tabTitle = "Main";
                break;
              case 1:
                _tabTitle = "Settings";
                break;

            }
          });
      },
    );

    return Scaffold(
      body: _tabPages[_currentTabIndex],
      bottomNavigationBar: bottomNavBar,
      appBar: _appBar,
    );
  }
}
