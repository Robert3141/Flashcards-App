import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flip_card/flip_card.dart';

Future main() async {
  runApp(new MyApp());
}

//
// CONSTANTS
//

// Default settings
final cardHeight = 100.0;
final cardWidth = 0.9;
final defaultCardAmount = 50;
final defaultCardsOrdered = false;

//prefs for flashcards page
int amountOfCards;
bool cardsOrdered;

class Strings{
  //British strings:

  //App Interface Main
  static String appName = "Flashcards";
  static String tabTitleMain = "Main";
  static String tabTitleSettings = "Settings";

  //App interface flashcards
  static String tabTitleFlashcards = "Flashcards";
  static String paddingAsText = "     ";

  //Default cards
  static String addNewCards = "Add New Flashcards";
  static String exampleFileName = "Example File";
  static String exampleFileLength = "3";
  static String exampleFileData = "card1a&card1b&card2a&card2b&card3a&card3b&";

  //Dialog Options
  static String importFlashcards = "Import File";
  static String createFlashcards = "Create New";
  static String editFlashcards = "Edit";
  static String loadFlashcards = "Load";
  static String errorOk = "OK";

  //Shared prefs storage names
  static String prefsFlashcardTitles = "Titles"; //Strings List
  static String prefsFlashcardLength = "Amount"; //Strings List
  static String prefsFlashcardData = "Data"; //Strings List
  static String prefsAmountOfCards = "Number"; //Integer
  static String prefsCardsOrdered = "Ordered"; //Boolean

  //Settings Options
  static String settingsCardsOrdered = "Order Cards";
  static String settingsAmountOfCards = "Amount Of Cards (Only when in shuffle)";

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
  bool _cardsAmountEnabled = defaultCardsOrdered;
  List<String> _flashcardFiles = ['${Strings.exampleFileName}'];
  List<String> _flashcardLengths = ['${Strings.exampleFileLength}'];
  final myController = TextEditingController();
  final _controllerAmountOfCards = TextEditingController();

  //
  // FUNCTIONS:
  //

  void outputErrors(String error,Element e){
    setState(() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(error),
          content: Text(e.toString()),
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
      String fileText = await _selectedFile.readAsString();

      //get name of text file from file path
      String fileName = splitter(_selectedFile.path, "/").last;

      //get amount of flashcards from file
      int fileCards = splitter(fileText, "&").length;
      fileCards = fileCards ~/ 2;

      //get SharedPrefs file
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> flashcardTitles = prefs.getStringList(Strings.prefsFlashcardTitles) ?? [fileName];
      List<String> flashcardLengths = prefs.getStringList(Strings.prefsFlashcardLength) ?? [fileCards.toString()];
      List<String> flashcardData = prefs.getStringList(Strings.prefsFlashcardData) ?? [fileText];

      //add file to prefs
      // flashcardData
      if (flashcardData[0] != fileText){
        flashcardData.add(fileText);
      }
      await prefs.setStringList(Strings.prefsFlashcardData,flashcardData);
      // flashcardTitles
      if (flashcardTitles[0] != fileName){
        flashcardTitles.add(fileName);
      }
      await prefs.setStringList(Strings.prefsFlashcardTitles,flashcardTitles);
      //flashcardLengths
      if (flashcardLengths[0] != fileCards.toString()) {
        flashcardLengths.add('$fileCards');
      }
      await prefs.setStringList(Strings.prefsFlashcardLength, flashcardLengths);

      setState(() {
        _flashcardFiles = flashcardTitles;
        _flashcardLengths = flashcardLengths;

        Navigator.pop(context);
      });


    } catch(e) {
      //in case of error output error
      outputErrors(Strings.errorImport, e);
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

  void clickEditFlashcards(int fileNumber) {
    // TODO: allow user to edit their flashcards
    try{

    } catch(e){
      //in case of error output error
      outputErrors(Strings.errorEdit, e);
    }
  }

  void clickLoadFlashcards(int fileNumber) async {
    try{
      //Get file from shared prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> flashcardsData = prefs.getStringList(Strings.prefsFlashcardData) ?? [Strings.exampleFileData];
      List<String> currentFlashcards = splitter(flashcardsData[fileNumber], "&");

      //load flashcards page
      Navigator.push(context, _FlashcardsPage(currentFlashcards));

    } catch(e){
      //in case of error output error
      outputErrors(Strings.errorLoad, e);
    }
  }

  void loadFromPreferences() async {
    try {
      //variables
      SharedPreferences prefs = await SharedPreferences.getInstance();

      //set variables
      _flashcardFiles = prefs.getStringList(Strings.prefsFlashcardTitles)?? [Strings.exampleFileName];
      _flashcardLengths = prefs.getStringList(Strings.prefsFlashcardLength)?? [Strings.exampleFileLength];
      amountOfCards = prefs.getInt(Strings.prefsAmountOfCards) ?? defaultCardAmount;
      _controllerAmountOfCards.text = amountOfCards.toString();
      cardsOrdered = prefs.getBool(Strings.prefsCardsOrdered) ?? defaultCardsOrdered;
      _cardsAmountEnabled = !cardsOrdered;
    } catch(e) {
      outputErrors(Strings.errorLoadPrefs, e);
    }
  }

  //
  // PREFERENCE UPDATES
  //

  void settingsOrderedCards(orderedCard) async {
    //set up prefs and save to prefs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(Strings.prefsCardsOrdered, orderedCard);
    cardsOrdered = orderedCard;
    setState(() {
      cardsOrdered = orderedCard;
      _cardsAmountEnabled = !orderedCard;
    });
  }

  void settingsCardAmount(cardAmountInput) async {
    if (num.tryParse(cardAmountInput.toString()) != null){
      //set up prefs and save to prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt(Strings.prefsAmountOfCards, num.parse(cardAmountInput.toString()));
    }
  }

  List<String> splitter(String splitText,String splitChar) {
    //local variables
    List<String> _fileList = [""];
    try {
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
      // TODO: make settings page work with dark/light theme and accent colour choice
      // TODO: add preferences/settings for all the necessary settings
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
                  Text(Strings.paddingAsText + Strings.settingsCardsOrdered, style: TextStyle(fontWeight: FontWeight.bold),),
                  Switch(value: cardsOrdered, onChanged: settingsOrderedCards,),
                ],
              ),
            ),
            Divider(),
            //Cards to show
            InkWell(
              splashColor: Theme.of(context).primaryColor,
              onTap: (){

              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    Strings.paddingAsText + Strings.settingsAmountOfCards,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(contentPadding: EdgeInsets.all(10.0)),
                      enabled: _cardsAmountEnabled,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                      onChanged: settingsCardAmount,
                      controller: _controllerAmountOfCards,
                    ),
                  ),

                ],
              ),
            )
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
        // TODO: work out why nav bar item titles don't accept Strings.tabTitle...
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

class _FlashcardsPage extends MaterialPageRoute<Null> {

  _FlashcardsPage(List<String> currentFileData) : super(builder: (BuildContext context){

    //set variables for class
    List<String> cardFront = [""];
    List<String> cardRear = [""];
    double screenWidth = MediaQuery.of(context).size.width;
    ScrollController scrollControl = new ScrollController();

    //
    // FUNCTIONS
    //

    void outputErrors(String error,e){
      /*showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(error),
          content: Text(e.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text(Strings.errorOk),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );*/ // NOT WORKING because it's stateless
      debugPrint(error + e.toString());
    }

    void newCard() {
      try {
        //cards ordered?
        if (cardsOrdered){
          //Cards need to be displayed in an ordered fashion

          //loop through array and add the flashcards
          cardFront[0] = currentFileData[0];
          cardRear[0] = currentFileData[1];
          for (var i = 2; i < currentFileData.length; i++) {
            //add to front if even and rear if odd
            if (i % 2 == 0) {
              cardFront.add(currentFileData[i]);
            } else {
              cardRear.add(currentFileData[i]);
            }
          }
        } else {
          //Cards can be outputted randomly with a limit

          //generate random
          Random rng = new Random();
          int randomNumber = 0;
          int amountOfFlashcards = currentFileData.length ~/ 2 - 1;

          // make random flashcard as next in list
          randomNumber = rng.nextInt(amountOfFlashcards * 2);
          cardFront[0] = currentFileData[randomNumber];
          cardRear[0] = currentFileData[randomNumber + 1];
          for (var i = 1; i < amountOfCards; i++) {
            randomNumber = rng.nextInt(amountOfFlashcards) * 2;
            cardFront.add(currentFileData[randomNumber]);
            cardRear.add(currentFileData[randomNumber + 1]);
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
                  itemCount: cardFront.length,//currentFileData.length ~/2 -1,
                  scrollDirection: Axis.horizontal,
                  controller: scrollControl,
                  key: Key("test"),
                  itemBuilder: (BuildContext context, int index) {
                    return FlipCard(
                      key: UniqueKey(),
                      direction: FlipDirection.HORIZONTAL,
                      speed: 1500,
                      front: InkWell(
                        child: Card(
                          child: Container(
                            width: screenWidth * cardWidth,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8.0))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(cardFront[index]),
                              ],
                            ),
                          ),
                        ),
                      ),
                      back: InkWell(
                        child: Card(
                          child: Container(
                            width: screenWidth * cardWidth,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8.0))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(cardRear[index]),
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
