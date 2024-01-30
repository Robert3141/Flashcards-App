import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashcards/UI/UIFlashcards.dart';
import 'package:flashcards/UI/UIEditCards.dart';
import 'package:flashcards/globals.dart' as globals;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dynamic_theme/flutter_dynamic_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';


import 'dart:developer' as developer;

extension ColorsExt on Color {

  MaterialColor toMaterialColor() {
    final int red = this.red;
    final int green = this.green;
    final int blue = this.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(value, shades);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  //set variables for class
  int _currentTabIndex = 0;
  var _tabTitle = globals.tabTitleMain;
  bool _cardsAmountEnabled = globals.defaultCardsOrdered;
  final _controllerAmountOfCards = TextEditingController();

  //
  // FUNCTIONS:
  //

  void outputErrors(String _error, _e) {
    setState(() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(_error),
          content: Text(_e.toString()),
          actions: <Widget>[
            TextButton(
              child: Text(globals.errorOk),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    });
  }

  void clickImportFlashcards() async {
    try {
      // Will filter and only let you pick files with svg and pdf extension
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['txt']);

      //error avoid
      if (result == null) {
        outputErrors(globals.errorImport, globals.errorNoFile);
        return;
      }

      //user file prompt:
      PlatformFile _selectedFile = result.files.first;

      //get text from file
      String _fileText =
          String.fromCharCodes(_selectedFile.bytes as Iterable<int>);

      //get name of text file from file path
      String _fileName =
          _selectedFile.name; //splitter(_selectedFile.path.trim(), "/").last;

      //get amount of flashcards from file
      int _fileCards = splitter(_fileText, "&").length;
      _fileCards = _fileCards ~/ 2;

      //get SharedPrefs file
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      List<String>? _flashcardTitles =
          _prefs.getStringList(globals.prefsFlashcardTitles);
      List<String>? _flashcardLengths =
          _prefs.getStringList(globals.prefsFlashcardLength);
      List<String>? _flashcardData =
          _prefs.getStringList(globals.prefsFlashcardData);

      //add file to prefs
      // flashcardTitles
      if (_flashcardTitles != null) {
        _flashcardTitles.add(_fileName);
      } else {
        _flashcardTitles = [_fileName];
      }
      //flashcardLengths
      if (_flashcardLengths != null) {
        _flashcardLengths.add('$_fileCards');
      } else {
        _flashcardLengths = [_fileCards.toString()];
      }
      // flashcardData
      if (_flashcardData != null) {
        _flashcardData.add(_fileText);
      } else {
        _flashcardData = [_fileText];
      }

      //save to shared prefs
      await _prefs.setStringList(globals.prefsFlashcardData, _flashcardData);
      await _prefs.setStringList(
          globals.prefsFlashcardTitles, _flashcardTitles);
      await _prefs.setStringList(
          globals.prefsFlashcardLength, _flashcardLengths);

      //update UI
      setState(() {
        globals.flashcardFiles = _flashcardTitles!;
        globals.flashcardLengths = _flashcardLengths!;

        Navigator.pop(context);
      });
    } catch (e) {
      //in case of error output error
      //print(e.runtimeType);
      if (e.runtimeType == FileSystemException) {
        outputErrors(globals.errorImport, globals.errorNotSupported);
      } else if (e.runtimeType == MissingPluginException) {
        outputErrors(globals.errorImport, globals.errorDeviceNotSupported);
      } else {
        outputErrors(globals.errorImport, e);
      }
    }
  }

  void clickOpenFlashcards() async {
    try {
      // Will filter and only let you pick files with svg and pdf extension
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['txt']);

      //error avoid
      if (result == null) {
        outputErrors(globals.errorImport, globals.errorNoFile);
        return;
      }

      //user file prompt:
      PlatformFile _selectedFile = result.files.first;

      //get text from file
      String _fileText = String.fromCharCodes(_selectedFile.bytes as Iterable<int>);

      //get list from file
      List<String> _currentFlashcards = splitter(_fileText, "&");

      //load flashcards page
      Navigator.push(context, FlashcardsPage(_currentFlashcards));
    } catch (e) {
      if (e.runtimeType == MissingPluginException) {
        outputErrors(globals.errorImport, globals.errorDeviceNotSupported);
      } else {
        outputErrors(globals.errorLoad, e);
      }
    }
  }

  void clickCreateFlashcards() async {
    try {
      // Get file from shared prefs
      int _newFileNumber = 0;
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      List<String>? _flashcardsData =
          _prefs.getStringList(globals.prefsFlashcardData);
      List<String>? _flashcardLengths =
          _prefs.getStringList(globals.prefsFlashcardLength);
      List<String>? _flashcardTitle =
          _prefs.getStringList(globals.prefsFlashcardTitles);

      //add file to sharedPrefs
      // flashcardData
      if (_flashcardsData != null) {
        _flashcardsData.add(globals.exampleFileData);
        _newFileNumber = _flashcardsData.length - 1;
      } else {
        _flashcardsData = [globals.exampleFileData];
      }
      await _prefs.setStringList(globals.prefsFlashcardData, _flashcardsData);
      // flashcardLengths
      if (_flashcardLengths != null) {
        _flashcardLengths.add(globals.exampleFileLength);
      } else {
        _flashcardLengths = [globals.exampleFileLength];
      }
      await _prefs.setStringList(
          globals.prefsFlashcardLength, _flashcardLengths);
      //flashcardTitle
      if (_flashcardTitle != null) {
        _flashcardTitle.add(globals.newFileName);
      } else {
        _flashcardTitle = [globals.newFileName];
      }
      await _prefs.setStringList(globals.prefsFlashcardTitles, _flashcardTitle);

      //split from file
      List<String> _currentFlashcards = splitter(globals.exampleFileData, "&");

      //load edit page
      Navigator.push(
          context, EditCardsPage(_currentFlashcards, _newFileNumber));
    } catch (e) {
      //in case of error output error
      outputErrors(globals.errorCreate, e);
    }
  }

  void clickEditFlashcards(int _fileNumber) async {
    try {
      //Get file from shared prefs
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      List<String> _flashcardData =
          _prefs.getStringList(globals.prefsFlashcardData) ?? [""];

      //split from file
      List<String> _currentFlashcards =
          splitter(_flashcardData[_fileNumber], "&");

      //load edit page
      await Navigator.push(
          context, EditCardsPage(_currentFlashcards, _fileNumber));

      //update UI
      setState(() {});
    } catch (e) {
      //in case of error output error
      outputErrors(globals.errorEdit, e);
    }
  }

  void clickLoadFlashcards(int _fileNumber) async {
    try {
      //Get file from shared prefs
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      List<String> _flashcardsData =
          _prefs.getStringList(globals.prefsFlashcardData) ??
              [globals.exampleFileData];
      List<String> _currentFlashcards =
          splitter(_flashcardsData[_fileNumber], "&");

      //load flashcards page
      Navigator.push(context, FlashcardsPage(_currentFlashcards));
    } catch (e) {
      //in case of error output error
      outputErrors(globals.errorLoad, e);
    }
  }

  void clickDeleteFlashcards(int _fileNumber) {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(globals.editDelete),
          content: Text(globals.editDeleting),
          actions: <Widget>[
            TextButton(
              child: Text(globals.errorCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(globals.errorOk),
              onPressed: () async {
                //load prefs
                SharedPreferences _prefs =
                    await SharedPreferences.getInstance();

                //get from shared prefs
                List<String>? _flashcardsData =
                    _prefs.getStringList(globals.prefsFlashcardData);

                //check not example file
                if (_flashcardsData != null) {
                  //get from shared prefs
                  globals.flashcardFiles =
                      _prefs.getStringList(globals.prefsFlashcardTitles)!;
                  globals.flashcardLengths =
                      _prefs.getStringList(globals.prefsFlashcardLength)!;

                  //remove file
                  _flashcardsData.removeAt(_fileNumber);
                  _prefs.setStringList(
                      globals.prefsFlashcardData, _flashcardsData);

                  //remove title
                  globals.flashcardFiles.removeAt(_fileNumber);
                  _prefs.setStringList(
                      globals.prefsFlashcardTitles, globals.flashcardFiles);

                  //remove number
                  globals.flashcardLengths.removeAt(_fileNumber);
                  _prefs.setStringList(
                      globals.prefsFlashcardLength, globals.flashcardLengths);

                  //reload interface
                  Navigator.pop(context);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
            )
          ],
        ),
      );
    } catch (e) {
      outputErrors(globals.errorDelete, e);
    }
  }

  void loadFromPreferences() async {
    try {
      //variables
      SharedPreferences _prefs = await SharedPreferences.getInstance();

      //set variables
      globals.flashcardFiles =
          _prefs.getStringList(globals.prefsFlashcardTitles) ??
              [globals.exampleFileName];
      globals.flashcardLengths =
          _prefs.getStringList(globals.prefsFlashcardLength) ??
              [globals.exampleFileLength];
      globals.amountOfCards = _prefs.getInt(globals.prefsAmountOfCards) ??
          globals.defaultCardAmount;
      _controllerAmountOfCards.text = globals.amountOfCards.toString();
      globals.cardsOrdered = _prefs.getBool(globals.prefsCardsOrdered) ??
          globals.defaultCardsOrdered;
      _cardsAmountEnabled = !globals.cardsOrdered;
    } catch (e) {
      outputErrors(globals.errorLoadPrefs, e);
    }
  }

  //
  // PREFERENCE UPDATES
  //

  void settingsOrderedCards(_orderedCard) async {
    try {
      //set up prefs and save to prefs
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setBool(globals.prefsCardsOrdered, _orderedCard);
      globals.cardsOrdered = _orderedCard;
      setState(() {
        globals.cardsOrdered = _orderedCard;
        _cardsAmountEnabled = !_orderedCard;
      });
    } catch (e) {
      outputErrors(globals.errorSettingsOrdered, e);
    }
  }

  void settingsCardAmount(_cardAmountInput) async {
    if (num.tryParse(_cardAmountInput.toString()) != null) {
      //set up prefs and save to prefs
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setInt(
          globals.prefsAmountOfCards, int.parse(_cardAmountInput.toString()));
    }
  }

  void settingsDarkTheme(bool _darkTheme) {
    try {
      //set up prefs and save to prefs
      /*DynamicTheme.of(context)
          ?.setTheme(/*_darkTheme ? AppThemes.DarkTheme :*/ AppThemes.LightTheme);*/
      developer.log(_darkTheme ? "Dark": "Light");
      FlutterDynamicTheme.of(context)?.setBrightness(_darkTheme ? Brightness.dark : Brightness.light);
    } catch (e) {
      outputErrors(globals.errorSettingsDark, e);
    }
  }

  void settingsThemeColor() {
    try {
      //local var
      Color _tempColor = Theme.of(context).primaryColor;
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(globals.settingsThemeColour),
              content: MaterialColorPicker(
                selectedColor: _tempColor,
                allowShades: true,
                onColorChange: (newColor) {
                  _tempColor = Color(newColor.value);
                },
                onMainColorChange: (newColor) {
                  _tempColor = Color(newColor!.value);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(globals.errorCancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(globals.errorOk),
                  onPressed: () {
                    FlutterDynamicTheme.of(context)?.setThemeData(
                          new ThemeData(
                            primarySwatch: _tempColor.toMaterialColor(),
                            primaryColor: _tempColor,

                          ));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } catch (e) {
      outputErrors(globals.errorSettingsTheme, e);
    }
  }

  List<String> splitter(String _splitText, String _splitChar) {
    //local variables
    List<String> _fileList = [""];
    try {
      String? _tempString = "";
      bool _firstTime = true;

      for (var i = 0; i < _splitText.length; i++) {
        if (_splitText[i] == _splitChar) {
          if (_tempString != null) {
            if (_firstTime) {
              _fileList[0] = _tempString;
              _firstTime = false;
            } else {
              _fileList.add(_tempString);
            }
          }
          _tempString = null;
        } else {
          if (_tempString == null) {
            _tempString = _splitText[i];
          } else {
            _tempString += _splitText[i];
          }
        }
      }

      if (_tempString != null) {
        _fileList.add(_tempString);
      }
    } catch (e) {
      outputErrors(globals.errorSplitString, e);
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
                height: globals.cardHeight,
                child: InkWell(
                  splashColor: Theme.of(context).primaryColor,
                  onTap: () {
                    setState(() {
                      //Add Cards dialog
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => SimpleDialog(
                          title: Text(globals.addNewCards),
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.folder_open),
                              title: Text(globals.importFlashcards),
                              onTap: () {
                                clickImportFlashcards();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.library_books),
                              title: Text(globals.openFlashcardsFile),
                              onTap: () {
                                clickOpenFlashcards();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.control_point),
                              title: Text(globals.createFlashcards),
                              onTap: () {
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
                      Text(globals.paddingAsText + globals.addNewCards,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.add),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: globals.flashcardFiles.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Container(
                      height: globals.cardHeight,
                      child: InkWell(
                        splashColor: Theme.of(context).primaryColor,
                        onTap: () {
                          //open cards dialog
                          setState(() {
                            //Add Cards dialog
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => SimpleDialog(
                                title: Text(globals.flashcardFiles[index]),
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text(globals.editFlashcards),
                                    onTap: () {
                                      clickEditFlashcards(index);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.content_copy),
                                    title: Text(globals.loadFlashcards),
                                    onTap: () {
                                      clickLoadFlashcards(index);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete_forever),
                                    title: Text(globals.deleteFlashcards),
                                    onTap: () {
                                      clickDeleteFlashcards(index);
                                    },
                                  )
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
                                child: Text(
                                    globals.paddingAsText +
                                        globals.flashcardFiles[index],
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(globals.flashcardLengths[index],
                                    overflow: TextOverflow.ellipsis),
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
      Container(
        child: ListView(
          children: <Widget>[
            // Cards Ordered
            InkWell(
              splashColor: Theme.of(context).primaryColor,
              onTap: () {
                settingsOrderedCards(!globals.cardsOrdered);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: globals.defaultPadding),
                      ),
                      Icon(Icons.reorder),
                      Text(
                        globals.paddingAsText + globals.settingsCardsOrdered,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Switch(
                    value: globals.cardsOrdered,
                    onChanged: settingsOrderedCards,
                  ),
                ],
              ),
            ),
            Divider(),
            //Cards to show
            InkWell(
              splashColor: Theme.of(context).primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: globals.defaultPadding),
                      ),
                      Icon(Icons.shuffle),
                      Text(
                        globals.paddingAsText + globals.settingsAmountOfCards,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(globals.defaultPadding),
                      child: TextField(
                        decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.all(globals.defaultPadding)),
                        enabled: _cardsAmountEnabled,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: settingsCardAmount,
                        controller: _controllerAmountOfCards,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            //set brightness
            InkWell(
              splashColor: Theme.of(context).primaryColor,
              onTap: () {
                settingsDarkTheme(
                    Theme.of(context).brightness == Brightness.light);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: globals.defaultPadding),
                      ),
                      Icon(Icons.brightness_3),
                      Text(
                        globals.paddingAsText + globals.settingsDarkTheme,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: settingsDarkTheme,
                  ),
                ],
              ),
            ),
            Divider(),
            //set theme
            InkWell(
              splashColor: Theme.of(context).primaryColor,
              onTap: () {
                settingsThemeColor();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: globals.defaultPadding),
                      ),
                      Icon(Icons.color_lens),
                      Text(
                        globals.paddingAsText + globals.settingsThemeColour,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];

    final _appBar = AppBar(
      title: Text(_tabTitle),
      centerTitle: true,
    );

    final bottomNavBar = BottomNavigationBar(
      currentIndex: _currentTabIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      type: BottomNavigationBarType.fixed,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.content_copy),
          label: globals.tabTitleFlashcards,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: globals.tabTitleSettings,
        ),
      ],
      onTap: (int index) {
        setState(() {
          _currentTabIndex = index;
          switch (index) {
            case 0:
              _tabTitle = globals.tabTitleMain;
              break;
            case 1:
              _tabTitle = globals.tabTitleSettings;
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
