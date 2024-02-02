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

extension ColorsExt on Color {
  MaterialColor toMaterialColor() {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = red, g = green, b = blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(value, swatch);
  }

  ColorScheme toColorScheme(Brightness brightness) {
    MaterialColor material = toMaterialColor();
    double lum = computeLuminance();
    scheme(Brightness b) => b == Brightness.light
        ? const ColorScheme.light()
        : const ColorScheme.dark();
    return scheme(brightness).copyWith(
      primary: this,
      onPrimary: lum > 0.5 ? material.shade600 : material.shade50,
      secondary: material.shade700,
      onSecondary: material.shade100,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

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

  void outputErrors(String error, e) {
    setState(() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(error),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              child: const Text(globals.errorOk),
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
      PlatformFile selectedFile = result.files.first;

      //get text from file
      String fileText =
          String.fromCharCodes(selectedFile.bytes as Iterable<int>);

      //get name of text file from file path
      String fileName =
          selectedFile.name; //splitter(_selectedFile.path.trim(), "/").last;

      //get amount of flashcards from file
      int fileCards = splitter(fileText, "&").length;
      fileCards = fileCards ~/ 2;

      //get SharedPrefs file
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? flashcardTitles =
          prefs.getStringList(globals.prefsFlashcardTitles);
      List<String>? flashcardLengths =
          prefs.getStringList(globals.prefsFlashcardLength);
      List<String>? flashcardData =
          prefs.getStringList(globals.prefsFlashcardData);

      //add file to prefs
      // flashcardTitles
      if (flashcardTitles != null) {
        flashcardTitles.add(fileName);
      } else {
        flashcardTitles = [fileName];
      }
      //flashcardLengths
      if (flashcardLengths != null) {
        flashcardLengths.add('$fileCards');
      } else {
        flashcardLengths = [fileCards.toString()];
      }
      // flashcardData
      if (flashcardData != null) {
        flashcardData.add(fileText);
      } else {
        flashcardData = [fileText];
      }

      //save to shared prefs
      await prefs.setStringList(globals.prefsFlashcardData, flashcardData);
      await prefs.setStringList(globals.prefsFlashcardTitles, flashcardTitles);
      await prefs.setStringList(globals.prefsFlashcardLength, flashcardLengths);

      //update UI
      setState(() {
        globals.flashcardFiles = flashcardTitles!;
        globals.flashcardLengths = flashcardLengths!;

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
      PlatformFile selectedFile = result.files.first;

      //get text from file
      String fileText =
          String.fromCharCodes(selectedFile.bytes as Iterable<int>);

      //get list from file
      List<String> currentFlashcards = splitter(fileText, "&");

      //load flashcards page
      if (!context.mounted) return;
      Navigator.push(context, FlashcardsPage(currentFlashcards));
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
      int newFileNumber = 0;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? flashcardsData =
          prefs.getStringList(globals.prefsFlashcardData);
      List<String>? flashcardLengths =
          prefs.getStringList(globals.prefsFlashcardLength);
      List<String>? flashcardTitle =
          prefs.getStringList(globals.prefsFlashcardTitles);

      //add file to sharedPrefs
      // flashcardData
      if (flashcardsData != null) {
        flashcardsData.add(globals.exampleFileData);
        newFileNumber = flashcardsData.length - 1;
      } else {
        flashcardsData = [globals.exampleFileData];
      }
      await prefs.setStringList(globals.prefsFlashcardData, flashcardsData);
      // flashcardLengths
      if (flashcardLengths != null) {
        flashcardLengths.add(globals.exampleFileLength);
      } else {
        flashcardLengths = [globals.exampleFileLength];
      }
      await prefs.setStringList(globals.prefsFlashcardLength, flashcardLengths);
      //flashcardTitle
      if (flashcardTitle != null) {
        flashcardTitle.add(globals.newFileName);
      } else {
        flashcardTitle = [globals.newFileName];
      }
      await prefs.setStringList(globals.prefsFlashcardTitles, flashcardTitle);

      //split from file
      List<String> currentFlashcards = splitter(globals.exampleFileData, "&");

      //load edit page
      if (!context.mounted) return;
      Navigator.push(context, EditCardsPage(currentFlashcards, newFileNumber));
    } catch (e) {
      //in case of error output error
      outputErrors(globals.errorCreate, e);
    }
  }

  void clickEditFlashcards(int fileNumber) async {
    try {
      //Get file from shared prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? flashcardData =
          prefs.getStringList(globals.prefsFlashcardData);

      //add example file to shared prefs
      if (flashcardData == null) {
        flashcardData = [globals.exampleFileData];
        prefs.setStringList(
            globals.prefsFlashcardData, [globals.exampleFileData]);

        //add title and amount of cards
        prefs.setStringList(
            globals.prefsFlashcardTitles, [globals.exampleFileName]);
        prefs.setStringList(
            globals.prefsFlashcardLength, [globals.exampleFileLength]);
      }

      //split from file
      List<String> currentFlashcards = splitter(flashcardData[fileNumber], "&");

      //load edit page
      if (!context.mounted) return;
      await Navigator.push(
          context, EditCardsPage(currentFlashcards, fileNumber));

      //update UI
      setState(() {});
    } catch (e) {
      //in case of error output error
      outputErrors(globals.errorEdit, e);
    }
  }

  void clickLoadFlashcards(int fileNumber) async {
    try {
      //Get file from shared prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> flashcardsData =
          prefs.getStringList(globals.prefsFlashcardData) ??
              [globals.exampleFileData];
      List<String> currentFlashcards =
          splitter(flashcardsData[fileNumber], "&");

      //load flashcards page
      if (!context.mounted) return;
      Navigator.push(context, FlashcardsPage(currentFlashcards));
    } catch (e) {
      //in case of error output error
      outputErrors(globals.errorLoad, e);
    }
  }

  void clickDeleteFlashcards(int fileNumber) {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(globals.editDelete),
          content: const Text(globals.editDeleting),
          actions: <Widget>[
            TextButton(
              child: const Text(globals.errorCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(globals.errorOk),
              onPressed: () async {
                //load prefs
                SharedPreferences prefs = await SharedPreferences.getInstance();

                //get from shared prefs
                List<String>? flashcardsData =
                    prefs.getStringList(globals.prefsFlashcardData);

                //check not example file
                if (flashcardsData != null) {
                  //get from shared prefs
                  globals.flashcardFiles =
                      prefs.getStringList(globals.prefsFlashcardTitles)!;
                  globals.flashcardLengths =
                      prefs.getStringList(globals.prefsFlashcardLength)!;

                  //remove file
                  flashcardsData.removeAt(fileNumber);
                  prefs.setStringList(
                      globals.prefsFlashcardData, flashcardsData);

                  //remove title
                  globals.flashcardFiles.removeAt(fileNumber);
                  prefs.setStringList(
                      globals.prefsFlashcardTitles, globals.flashcardFiles);

                  //remove number
                  globals.flashcardLengths.removeAt(fileNumber);
                  prefs.setStringList(
                      globals.prefsFlashcardLength, globals.flashcardLengths);

                  //reload interface
                  if (!context.mounted) return;
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
      SharedPreferences prefs = await SharedPreferences.getInstance();

      //set variables
      globals.flashcardFiles =
          prefs.getStringList(globals.prefsFlashcardTitles) ??
              [globals.exampleFileName];
      globals.flashcardLengths =
          prefs.getStringList(globals.prefsFlashcardLength) ??
              [globals.exampleFileLength];
      globals.amountOfCards =
          prefs.getInt(globals.prefsAmountOfCards) ?? globals.defaultCardAmount;
      _controllerAmountOfCards.text = globals.amountOfCards.toString();
      globals.cardsOrdered = prefs.getBool(globals.prefsCardsOrdered) ??
          globals.defaultCardsOrdered;
      _cardsAmountEnabled = !globals.cardsOrdered;
    } catch (e) {
      outputErrors(globals.errorLoadPrefs, e);
    }
  }

  //
  // PREFERENCE UPDATES
  //

  void settingsOrderedCards(orderedCard) async {
    try {
      //set up prefs and save to prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(globals.prefsCardsOrdered, orderedCard);
      globals.cardsOrdered = orderedCard;
      setState(() {
        globals.cardsOrdered = orderedCard;
        _cardsAmountEnabled = !orderedCard;
      });
    } catch (e) {
      outputErrors(globals.errorSettingsOrdered, e);
    }
  }

  void settingsCardAmount(cardAmountInput) async {
    if (num.tryParse(cardAmountInput.toString()) != null) {
      //set up prefs and save to prefs
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt(
          globals.prefsAmountOfCards, int.parse(cardAmountInput.toString()));
    }
  }

  void settingsDarkTheme(bool darkTheme) {
    try {
      FlutterDynamicTheme.of(context)?.setThemeData(ThemeData(
          primarySwatch: Theme.of(context).primaryColor.toMaterialColor(),
          primaryColor: Theme.of(context).primaryColor,
          brightness: darkTheme ? Brightness.dark : Brightness.light,
          colorScheme: Theme.of(context)
              .primaryColor
              .toColorScheme(darkTheme ? Brightness.dark : Brightness.light)));
    } catch (e) {
      outputErrors(globals.errorSettingsDark, e);
    }
  }

  void settingsThemeColor() {
    try {
      //local var
      //Color _tempColor = Theme.of(context).primaryColor;
      ColorScheme tempColor = Theme.of(context).colorScheme;
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text(globals.settingsThemeColour),
              content: MaterialColorPicker(
                selectedColor: tempColor.primary,
                allowShades: true,
                onColorChange: (newColor) {
                  setState(() {
                    tempColor = tempColor.copyWith(primary: newColor);
                  });
                },
                onMainColorChange: (newColor) {
                  //_tempColor = ColorScheme.fromSwatch(primarySwatch: newColor);
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(globals.errorCancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(globals.errorOk),
                  onPressed: () {
                    FlutterDynamicTheme.of(context)?.setThemeData(ThemeData(
                        primarySwatch: tempColor.primary.toMaterialColor(),
                        primaryColor: tempColor.primary,
                        brightness: FlutterDynamicTheme.of(context)
                            ?.themeData
                            .brightness,
                        colorScheme: tempColor));
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

  List<String> splitter(String splitText, String splitChar) {
    //local variables
    List<String> fileList = [""];
    try {
      String? tempString = "";
      bool firstTime = true;

      for (var i = 0; i < splitText.length; i++) {
        if (splitText[i] == splitChar) {
          if (tempString != null) {
            if (firstTime) {
              fileList[0] = tempString;
              firstTime = false;
            } else {
              fileList.add(tempString);
            }
          }
          tempString = null;
        } else {
          if (tempString == null) {
            tempString = splitText[i];
          } else {
            tempString += splitText[i];
          }
        }
      }

      if (tempString != null) {
        fileList.add(tempString);
      }
    } catch (e) {
      outputErrors(globals.errorSplitString, e);
    }

    return fileList;
  }

  @override
  Widget build(BuildContext context) {
    //build the page with the flashcards
    loadFromPreferences();
    final tabPages = <Widget>[
      //Main Tab
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Card(
            child: SizedBox(
              height: globals.cardHeight,
              child: InkWell(
                splashColor: Theme.of(context).primaryColor,
                onTap: () {
                  setState(() {
                    //Add Cards dialog
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => SimpleDialog(
                        title: const Text(globals.addNewCards),
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.folder_open),
                            title: const Text(globals.importFlashcards),
                            onTap: () {
                              clickImportFlashcards();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.library_books),
                            title: const Text(globals.openFlashcardsFile),
                            onTap: () {
                              clickOpenFlashcards();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.control_point),
                            title: const Text(globals.createFlashcards),
                            onTap: () {
                              clickCreateFlashcards();
                            },
                          ),
                        ],
                      ),
                    );
                  });
                },
                child: const Row(
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
                  child: SizedBox(
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
                                  leading: const Icon(Icons.edit),
                                  title: const Text(globals.editFlashcards),
                                  onTap: () {
                                    clickEditFlashcards(index);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.content_copy),
                                  title: const Text(globals.loadFlashcards),
                                  onTap: () {
                                    clickLoadFlashcards(index);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete_forever),
                                  title: const Text(globals.deleteFlashcards),
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
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Text(
                                  globals.paddingAsText +
                                      globals.flashcardFiles[index],
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(globals.flashcardLengths[index],
                                  overflow: TextOverflow.ellipsis),
                              const Icon(Icons.content_copy),
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

      //Settings Tab
      ListView(
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
                const Row(
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
          const Divider(),
          //Cards to show
          InkWell(
            splashColor: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Row(
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
                    padding: const EdgeInsets.all(globals.defaultPadding),
                    child: TextField(
                      decoration: const InputDecoration(
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
          const Divider(),
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
                const Row(
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
          const Divider(),
          //set theme
          InkWell(
            splashColor: Theme.of(context).primaryColor,
            onTap: () {
              settingsThemeColor();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Row(
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
    ];

    final appBar = AppBar(
      title:
          Text(_tabTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      foregroundColor: Theme.of(context).primaryColor,
    );

    final bottomNavBar = BottomNavigationBar(
      currentIndex: _currentTabIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
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
      body: tabPages[_currentTabIndex],
      bottomNavigationBar: bottomNavBar,
      appBar: appBar,
    );
  }
}
