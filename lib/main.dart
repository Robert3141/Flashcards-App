import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  runApp(new MyApp());
}

//
// CONSTANTS
//

final cardHeight = 100.0;
class Strings{
  //British strings:

  //App Interface
  static String appName = "Flashcards";
  static String tabTitleMain = "Main";
  static String tabTitleSettings = "Settings";

  //Default cards
  static String addNewCards = "Add New Flashcards";
  static String exampleFileName = "Example File";
  static String exampleFileLength = "3";

  //Flashcard Options
  static String importFlashcards = "Import File";
  static String createFlashcards = "Create New";
  static String editFlashcards = "Edit";
  static String loadFlashcards = "Load";

  //Shared prefs storage names
  static String prefsFlashcardTitles = "Titles"; //Strings List
  static String prefsFlashcardData = "Data"; //Strings List
  static String prefsFlashcardLength = "Amount"; //Strings List

}



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
      title: Strings.appName,
      theme: new ThemeData(
        //app theme
        primarySwatch: Colors.blue,
        brightness: darkThemeEnabled?Brightness.dark:Brightness.light,
      ),
      home: new MyHomePage(
        title: Strings.appName,
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
  //set variables for class
  int _currentTabIndex = 0;
  var _tabTitle = Strings.tabTitleMain;
  List<String> _flashcardFiles = ['${Strings.exampleFileName}'];
  List<String> _flashcardLengths = ['${Strings.exampleFileLength}'];
  final myController = TextEditingController();

  //functions
  void clickImportFlashcards() async {
    /*try {
      //local vars
      File file = await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'txt');
      String fileText = await file.readAsString();
      String fileName = splitter(file.path, "/").last;
      debugPrint(fileName);
      int fileCards = splitter(fileText,"&").length ~/ 2;
      debugPrint(fileCards.toString());
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

    });*/
    try {
      //user file prompt:
      File _selectedFile = await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'txt');

      //get text from file
      String fileText = await _selectedFile.readAsString();

      //get name of text file from file path
      String fileName = splitter(_selectedFile.path, "/").last;
      debugPrint("fileName=" + fileName);

      //get amount of flashcards from file
      int fileCards = splitter(fileText, "&").length;
      fileCards = fileCards ~/ 2;
      debugPrint("fileCards=" + fileCards.toString());

      //get SharedPrefs file



    } catch(e) {
      debugPrint("Error clickImportFlashcards(): " + e.toString());
    }
    // TODO: get flashcard import setup and working bug free

  }



  void clickCreateFlashcards() {
    // TODO: allow user to create flashcard set from within the app
  }

  void clickEditFlashcards(int fileNumber) {
    // TODO: allow user to edit their flashcards
  }

  void clickLoadFlashcards(int fileNumber) {
    // TODO: make flashcards load on screen and appear for testing
  }


  void loadFromPreferences() async {
    // TODO: make sure preferences are loaded correctly
    //variables
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //set variables
    _flashcardFiles = prefs.getStringList(Strings.prefsFlashcardTitles)?? [Strings.exampleFileName];
    _flashcardLengths = prefs.getStringList(Strings.prefsFlashcardLength)?? [Strings.exampleFileLength];
  }

  List<String> splitter(String splitText,String splitChar) {
    //local variables
    List<String> _fileList = [""];
    var _tempString = "";
    bool _firstTime = true;

    for (var i = 0; i < splitText.length; i++) {
      if (splitText[i] == splitChar){
        if (_tempString != null){
          if(_firstTime){
            _fileList[0] = _tempString;
            _firstTime = false;
          } else {
            _fileList.add(_tempString);
          }
        }
        _tempString = null;
      } else {
        if(_tempString == null){
          _tempString = splitText[i];
        } else {
          _tempString += splitText[i];
        }
      }
    }

    if (_tempString != null){
      _fileList.add(_tempString);
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
                              title: Text(Strings.addNewCards),
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.folder_open),
                                  title: Text(Strings.importFlashcards),
                                  onTap: (){
                                    clickImportFlashcards();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.control_point),
                                  title: Text(Strings.createFlashcards),
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
                          Text("     " + Strings.addNewCards,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.add),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: _flashcardFiles.length - 1,
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
                                          title: Text(Strings.editFlashcards),
                                          onTap: (){
                                            clickEditFlashcards(index);
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.content_copy),
                                          title: Text(Strings.loadFlashcards),
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

                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(right: 4.0),
                                      child: Text('     '+_flashcardFiles[index],overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),

                                    ),
                                  ),


                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(_flashcardLengths[index],overflow: TextOverflow.ellipsis),
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

      //Settings Tab
      // TODO: make settings page work with dark/light theme and accent colour choice
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(Strings.tabTitleSettings),
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
        // TODO: work out why navbar item titles don't accept Strings.tabTitle...
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
                _tabTitle = Strings.tabTitleMain;
                break;
              case 1:
                _tabTitle = Strings.tabTitleSettings;
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
