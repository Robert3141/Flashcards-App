import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flip_card/flip_card.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

Future main() async {
  runApp(new MyApp());
}

//
// CONSTANTS
//

// Default settings
final cardHeight = 100.0;
final cardWidth = 0.9;
final defaultPadding = 12.0;
final defaultCardAmount = 50;
final defaultCardsOrdered = false;
final defaultThemeColor = Colors.blue;
final defaultBrightness = Brightness.light;

//prefs for flashcards page
int amountOfCards;
bool cardsOrdered;

class Strings{
  //British strings:

  //App Interface Main
  static String appName = "Flashcards";
  static String tabTitleMain = "Main";
  static String tabTitleSettings = "Settings";
  static String tabTitleFlashcards = "Flashcards";
  static String tabTitleEditCards = "Edit Cards";
  static String paddingAsText = "     ";

  //Default cards
  static String addNewCards = "Add New Flashcards";
  static String exampleFileName = "Example File";
  static String exampleFileLength = "3";
  static String exampleFileData = "card1a&card1b&card2a&card2b&card3a&card3b&";

  //Dialog Options
  static String importFlashcards = "Import File";
  static String openFlashcardsFile = "Open File";
  static String createFlashcards = "Create New";
  static String editFlashcards = "Edit";
  static String loadFlashcards = "Load";
  static String errorOk = "OK";
  static String errorCancel = "CANCEL";

  //Shared prefs storage names
  static String prefsFlashcardTitles = "Titles"; //Strings List
  static String prefsFlashcardLength = "Amount"; //Strings List
  static String prefsFlashcardData = "Data"; //Strings List
  static String prefsAmountOfCards = "Number"; //Integer
  static String prefsCardsOrdered = "Ordered"; //Boolean

  //Settings Options
  static String settingsCardsOrdered = "Order Cards";
  static String settingsAmountOfCards = "Amount Of Cards (Only when in shuffle)";
  static String settingsDarkTheme = "Dark Theme";
  static String settingsThemeColour = "Theme Colour (Only when in light theme)";

  //Error Messages
  static String errorImport = "Error Importing Flashcards:\n";
  static String errorCreate = "Error Creating Flashcards:\n";
  static String errorEdit = "Error Editing Flashcards:\n";
  static String errorLoad = "Error Loading Flashcards:\n";
  static String errorNewCard = "Error Getting Next Flashcard:\n";
  static String errorLoadPrefs = "Error Loading Settings:\n";
  static String errorSplitString = "Internal Error:\n";

}



class MyApp extends StatefulWidget {

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    return new DynamicTheme(
      defaultBrightness: defaultBrightness,
      data: (brightness) => new ThemeData(
        primarySwatch: defaultThemeColor,
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return new MaterialApp(
          title: Strings.appName,
          theme: theme,
          darkTheme: new ThemeData(
            primarySwatch: defaultThemeColor,
            brightness: Brightness.dark,
          ),
          home: new MyHomePage(title: Strings.appName,),
        );
      },
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
  bool _cardsAmountEnabled = defaultCardsOrdered;
  List<String> _flashcardFiles = ['${Strings.exampleFileName}'];
  List<String> _flashcardLengths = ['${Strings.exampleFileLength}'];
  final _controllerAmountOfCards = TextEditingController();

  //
  // FUNCTIONS:
  //

  void outputErrors(String _error,_e){
    setState(() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(_error),
          content: Text(_e.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text(Strings.errorOk),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    });
  }

  void clickImportFlashcards() async {
    try {
      //user file prompt:
      File _selectedFile = await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'txt');

      //get text from file
      String _fileText = await _selectedFile.readAsString();

      //get name of text file from file path
      String _fileName = splitter(_selectedFile.path, "/").last;

      //get amount of flashcards from file
      int _fileCards = splitter(_fileText, "&").length;
      _fileCards = _fileCards ~/ 2;

      //get SharedPrefs file
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      List<String> _flashcardTitles = _prefs.getStringList(Strings.prefsFlashcardTitles) ?? [_fileName];
      List<String> _flashcardLengths = _prefs.getStringList(Strings.prefsFlashcardLength) ?? [_fileCards.toString()];
      List<String> _flashcardData = _prefs.getStringList(Strings.prefsFlashcardData) ?? [_fileText];

      //add file to prefs
      // flashcardData
      if (_flashcardData[0] != _fileText){
        _flashcardData.add(_fileText);
      }
      await _prefs.setStringList(Strings.prefsFlashcardData,_flashcardData);
      // flashcardTitles
      if (_flashcardTitles[0] != _fileName){
        _flashcardTitles.add(_fileName);
      }
      await _prefs.setStringList(Strings.prefsFlashcardTitles,_flashcardTitles);
      //flashcardLengths
      if (_flashcardLengths[0] != _fileCards.toString()) {
        _flashcardLengths.add('$_fileCards');
      }
      await _prefs.setStringList(Strings.prefsFlashcardLength, _flashcardLengths);

      setState(() {
        _flashcardFiles = _flashcardTitles;
        _flashcardLengths = _flashcardLengths;

        Navigator.pop(context);
      });


    } catch(e) {
      //in case of error output error
      outputErrors(Strings.errorImport, e);
    }
  }

  void clickOpenFlashcards() async {
    try {
      //user file prompt:
      File _selectedFile = await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'txt');

      //get text from file
      String _fileText = await _selectedFile.readAsString();

      //get list from file
      List<String> _currentFlashcards = splitter(_fileText, "&");

      //load flashcards page
      Navigator.push(context, _FlashcardsPage(_currentFlashcards));

    } catch(e) {
      outputErrors(Strings.errorLoad, e);
    }
  }

  void clickCreateFlashcards() {
    // TODO: allow user to create flashcard set from within the app
    try{

    } catch(e){
      //in case of error output error
      outputErrors(Strings.errorCreate, e);
    }
  }

  void clickEditFlashcards(int _fileNumber) async {
    // TODO: allow user to edit their flashcards
    try{
      //Get file from shared prefs
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      List<String> _flashcardData = _prefs.getStringList(Strings.prefsFlashcardData);

      //add example file to shared prefs
      if (_flashcardData == null) {
        debugPrint("YAY");
        _flashcardData = [Strings.exampleFileData];
        _prefs.setStringList(Strings.prefsFlashcardData, [Strings.exampleFileData]);
      }

      //split from file
      List<String> _currentFlashcards = splitter(_flashcardData[_fileNumber], "&");

      //load edit page
      Navigator.push(context, _EditCardsPage(_currentFlashcards, _fileNumber));

    } catch(e){
      //in case of error output error
      outputErrors(Strings.errorEdit, e);
    }
  }

  void clickLoadFlashcards(int _fileNumber) async {
    try{
      //Get file from shared prefs
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      List<String> _flashcardsData = _prefs.getStringList(Strings.prefsFlashcardData) ?? [Strings.exampleFileData];
      List<String> _currentFlashcards = splitter(_flashcardsData[_fileNumber], "&");

      //load flashcards page
      Navigator.push(context, _FlashcardsPage(_currentFlashcards));

    } catch(e){
      //in case of error output error
      outputErrors(Strings.errorLoad, e);
    }
  }

  void loadFromPreferences() async {
    try {
      //variables
      SharedPreferences _prefs = await SharedPreferences.getInstance();

      //set variables
      _flashcardFiles = _prefs.getStringList(Strings.prefsFlashcardTitles)?? [Strings.exampleFileName];
      _flashcardLengths = _prefs.getStringList(Strings.prefsFlashcardLength)?? [Strings.exampleFileLength];
      amountOfCards = _prefs.getInt(Strings.prefsAmountOfCards) ?? defaultCardAmount;
      _controllerAmountOfCards.text = amountOfCards.toString();
      cardsOrdered = _prefs.getBool(Strings.prefsCardsOrdered) ?? defaultCardsOrdered;
      _cardsAmountEnabled = !cardsOrdered;
    } catch(e) {
      outputErrors(Strings.errorLoadPrefs, e);
    }
  }

  //
  // PREFERENCE UPDATES
  //

  void settingsOrderedCards(_orderedCard) async {
    //set up prefs and save to prefs
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setBool(Strings.prefsCardsOrdered, _orderedCard);
    cardsOrdered = _orderedCard;
    setState(() {
      cardsOrdered = _orderedCard;
      _cardsAmountEnabled = !_orderedCard;
    });
  }

  void settingsCardAmount(_cardAmountInput) async {
    if (num.tryParse(_cardAmountInput.toString()) != null){
      //set up prefs and save to prefs
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setInt(Strings.prefsAmountOfCards, num.parse(_cardAmountInput.toString()));
    }
  }

  void settingsDarkTheme(_darkTheme) {
    //set up prefs and save to prefs
    DynamicTheme.of(context).setBrightness(_darkTheme? Brightness.dark : Brightness.light);
  }

  void settingsThemeColor() {
    //local var
    Color _tempColor = Theme.of(context).primaryColor;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(Strings.settingsThemeColour),
          content: MaterialColorPicker(
            selectedColor: Theme.of(context).primaryColor,
            allowShades: true,
            onColorChange: (newColor) {
              _tempColor = Color(newColor.value);
            },

            onMainColorChange: (newColor) {
              _tempColor = Color(newColor.value);
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(Strings.errorCancel),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(Strings.errorOk),
              onPressed: (){
                DynamicTheme.of(context).setBrightness(Brightness.light);
                DynamicTheme.of(context).setThemeData(new ThemeData(primaryColor: _tempColor, accentColor: _tempColor));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  List<String> splitter(String _splitText,String _splitChar) {
    //local variables
    List<String> _fileList = [""];
    try {
      var _tempString = "";
      bool _firstTime = true;

      for (var i = 0; i < _splitText.length; i++) {
        if (_splitText[i] == _splitChar){
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
            _tempString = _splitText[i];
          } else {
            _tempString += _splitText[i];
          }
        }
      }

      if (_tempString != null){
        _fileList.add(_tempString);
      }
    } catch(e) {
      outputErrors(Strings.errorSplitString, e);
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
                                  leading: Icon(Icons.library_books),
                                  title: Text(Strings.openFlashcardsFile),
                                  onTap: (){
                                    clickOpenFlashcards();
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
                          Text(Strings.paddingAsText + Strings.addNewCards,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      child: Text(Strings.paddingAsText + _flashcardFiles[index],overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),

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
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Cards Ordered
            InkWell(
              splashColor: Theme.of(context).primaryColor,
              onTap: (){
                settingsOrderedCards(!cardsOrdered);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(left: defaultPadding),),
                      Icon(Icons.reorder),
                      Text(Strings.paddingAsText + Strings.settingsCardsOrdered, style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Switch(value: cardsOrdered, onChanged: settingsOrderedCards,),
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
                      Padding(padding: EdgeInsets.only(left: defaultPadding),),
                      Icon(Icons.shuffle),
                      Text(
                        Strings.paddingAsText + Strings.settingsAmountOfCards,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(defaultPadding),
                      child: TextField(
                        decoration: InputDecoration(contentPadding: EdgeInsets.all(defaultPadding)),
                        enabled: _cardsAmountEnabled,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
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
              onTap: (){
                settingsDarkTheme(Theme.of(context).brightness == Brightness.light);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(left: defaultPadding),),
                      Icon(Icons.brightness_3),
                      Text(
                        Strings.paddingAsText + Strings.settingsDarkTheme,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  Switch(value: Theme.of(context).brightness == Brightness.dark, onChanged: settingsDarkTheme,),
                ],
              ),
            ),
            Divider(),
            //set theme
            InkWell(
              splashColor: Theme.of(context).primaryColor,
              onTap: (){
                settingsThemeColor();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(left: defaultPadding),),
                      Icon(Icons.color_lens),
                      Text(
                        Strings.paddingAsText + Strings.settingsThemeColour,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CircleAvatar(backgroundColor: Theme.of(context).accentColor,),
                ],
              ),
            ),
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
      items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.content_copy),
            title: Text(Strings.tabTitleFlashcards),

          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text(Strings.tabTitleSettings),
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

class _FlashcardsPage extends MaterialPageRoute<Null> {

  _FlashcardsPage(List<String> _currentFileData) : super(builder: (BuildContext context){

    //set variables for class
    List<String> _cardFront = [""];
    List<String> _cardRear = [""];
    double _screenWidth = MediaQuery.of(context).size.width;
    ScrollController _scrollControl = new ScrollController();

    //
    // FUNCTIONS
    //

    void outputErrors(String _error,_e){
      /*showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(_error),
          content: Text(_e.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text(Strings.errorOk),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );*/ // NOT WORKING because it's stateless
      debugPrint(_error + _e.toString());
    }

    void newCard() {
      try {
        //cards ordered?
        if (cardsOrdered){
          //Cards need to be displayed in an ordered fashion

          //loop through array and add the flashcards
          _cardFront[0] = _currentFileData[0];
          _cardRear[0] = _currentFileData[1];
          for (var i = 2; i < _currentFileData.length; i++) {
            //add to front if even and rear if odd
            if (i % 2 == 0) {
              _cardFront.add(_currentFileData[i]);
            } else {
              _cardRear.add(_currentFileData[i]);
            }
          }
        } else {
          //Cards can be outputted randomly with a limit

          //generate random
          Random _rng = new Random();
          int _randomNumber = 0;
          int _amountOfFlashcards = _currentFileData.length ~/ 2 - 1;

          // make random flashcard as next in list
          _randomNumber = _rng.nextInt(_amountOfFlashcards * 2);
          _cardFront[0] = _currentFileData[_randomNumber];
          _cardRear[0] = _currentFileData[_randomNumber + 1];
          for (var i = 1; i < amountOfCards; i++) {
            _randomNumber = _rng.nextInt(_amountOfFlashcards) * 2;
            _cardFront.add(_currentFileData[_randomNumber]);
            _cardRear.add(_currentFileData[_randomNumber + 1]);
          }
          
        }


      } catch(e) {
        outputErrors(Strings.errorNewCard, e);
      }
    }

    //
    // LOAD INTERFACE
    //
    newCard();
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.tabTitleFlashcards),
        elevation: 1.0,
      ),
      body: Builder(
        builder: (BuildContext context) => Container(
          color: Theme.of(context).primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: ListView.builder(
                  itemCount: _cardFront.length,//currentFileData.length ~/2 -1,
                  scrollDirection: Axis.horizontal,
                  controller: _scrollControl,
                  key: Key("test"),
                  itemBuilder: (BuildContext context, int index) {
                    return FlipCard(
                      key: UniqueKey(),
                      direction: FlipDirection.HORIZONTAL,
                      speed: 1500,
                      front: InkWell(
                        child: Card(
                          child: Container(
                            width: _screenWidth * cardWidth,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8.0))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(defaultPadding),
                                  child: Text(_cardFront[index]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      back: InkWell(
                        child: Card(
                          child: Container(
                            width: _screenWidth * cardWidth,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8.0))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(defaultPadding),
                                  child: Text(_cardRear[index]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              /*Expanded(
                flex: 1,
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          child: Card(
                            child: Icon(Icons.arrow_back_ios),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          child: Card(
                            child: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )*/ //Adding buttons later
            ],
          ),
        ),

      ),
    );
  });
}

class _EditCardsPage extends MaterialPageRoute<Null> {

  _EditCardsPage(List<String> _currentFileData, int _currentFileNo) : super(builder: (BuildContext context){
    // LOCAL VARS
    final _controllerFront = TextEditingController();
    final _controllerRear = TextEditingController();

    void _cardChanged(String _newCard, int _index, bool _frontOfCard) async {
      //local vars
      String _currentFileDataString = "" ;

      //update current card
      if(_frontOfCard){
        _currentFileData[_index * 2] = _newCard;
      } else {
        _currentFileData[_index * 2 + 1] = _newCard;
      }


      //compress string to list
      for (var i = 0; i < _currentFileData.length; i++) {
        _currentFileDataString += _currentFileData[i] + "&";
      }

      //load prefs
      SharedPreferences _prefs = await SharedPreferences.getInstance();

      //get string list
      List<String> _currentFlashcardData = _prefs.getStringList(Strings.prefsFlashcardData);

      //update string list
      _currentFlashcardData[_currentFileNo] = _currentFileDataString;

      //save to prefs
      _prefs.setStringList(Strings.prefsFlashcardData, _currentFlashcardData);
    }

    //
    // LOAD INTERFACE
    //
    return Scaffold(
      appBar: AppBar(
        title:Text(Strings.tabTitleEditCards),
        elevation: 1.0,
      ),
      body: Builder(
        builder: (BuildContext context) => Container(
          color: Theme.of(context).primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: _currentFileData.length ~/ 2,
                  itemBuilder: (BuildContext context, int index){
                    return Card(
                      child: Container(
                        height: cardHeight,
                        child: InkWell(
                          splashColor: Theme.of(context).primaryColor,
                          onTap: (){
                            //set text of dialog
                            _controllerFront.text = _currentFileData[index * 2];
                            _controllerRear.text = _currentFileData[index * 2 + 1];

                            //open cards dialog
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => SimpleDialog(
                                title: Text("Card no. " + (index + 1).toString()),
                                children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(defaultPadding),
                                      child: TextField(
                                        decoration: InputDecoration(hintText: "Front of card"),
                                        onChanged: (_newCard){
                                          _cardChanged(_newCard, index, true);
                                        },
                                        controller: _controllerFront,
                                      ),
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: EdgeInsets.all(defaultPadding),
                                      child: TextField(
                                        decoration: InputDecoration(hintText: "Rear of card"),
                                        onChanged: (_newCard){
                                          _cardChanged(_newCard, index, false);
                                        },
                                        controller: _controllerRear,
                                      ),
                                    ),
                                ],
                              ),
                            );

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(Strings.paddingAsText + _currentFileData[index * 2], overflow: TextOverflow.ellipsis,),
                              Text(_currentFileData[index * 2 + 1] + Strings.paddingAsText, overflow: TextOverflow.ellipsis,),
                              //Text(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  });
}

/*class EditCardsPopup extends StatefulWidget {
  EditCardsPopup({
    Key key,
    int index,
    List<String> flashcardFile,
}) : super (key: key);

  @override
  _EditCardsPopupState createState() => new _EditCardsPopupState();
}

class _EditCardsPopupState extends State<EditCardsPopup> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Builder(builder: (BuildContext context) => SimpleDialog(
      title: Text('Edit cards no.'),
    ));
  }
}*/
