import 'package:flutter/material.dart';
import 'package:flashcards/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

class EditCardsPage extends MaterialPageRoute<void> {
  EditCardsPage(List<String> currentFileData, int currentFileNo)
      : super(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(globals.tabTitleEditCards),
              elevation: 1.0,
            ),
            body: Builder(
              builder: (BuildContext context) => EditCards(
                  currentFileData: currentFileData,
                  currentFileNo: currentFileNo,
              ),
            ),
          );
        });
}

class EditCards extends StatefulWidget {
  const EditCards(
      {required this.currentFileData,
      required this.currentFileNo,
      Key? key,
      int index = 0})
      : super(key: key);

  final List<String> currentFileData;
  final int currentFileNo;

  static const String routeName = "/EditCards";

  @override
  EditCardsState createState() => EditCardsState();
}

class EditCardsState extends State<EditCards> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // LOCAL VARS
    final controllerFront = TextEditingController();
    final controllerRear = TextEditingController();
    final controllerTitle = TextEditingController();
    List<String> currentFileData = widget.currentFileData;
    int currentFileNo = widget.currentFileNo;
    ScrollController scrolly = ScrollController();

    //
    // FUNCTIONS
    //

    void outputErrors(String error, e) {
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
    }

    void onLoad() async {
      try {
        //get shared prefs
        SharedPreferences prefs = await SharedPreferences.getInstance();

        //get title
        controllerTitle.text =
            prefs.getStringList(globals.prefsFlashcardTitles)?[currentFileNo] ?? "";
      } catch (e) {
        outputErrors(globals.errorLoadPrefs, e);
      }
    }

    void updatePrefs() async {
      try {
        //local vars
        String currentFileDataString = "";

        //compress string to list
        for (var i = 0; i < currentFileData.length; i++) {
          currentFileDataString += "${currentFileData[i]}&";
        }

        //load prefs
        SharedPreferences prefs = await SharedPreferences.getInstance();

        //get string list
        List<String> currentFlashcardData =
            prefs.getStringList(globals.prefsFlashcardData) ?? [];

        //update string list
        currentFlashcardData[currentFileNo] = currentFileDataString;

        //save to prefs
        prefs.setStringList(globals.prefsFlashcardData, currentFlashcardData);
      } catch (e) {
        outputErrors(globals.errorEditPrefs, e);
      }
    }

    void cardChanged(String newCard, int index, bool frontOfCard) async {
      try {
        //check first that & not used
        bool andUsed = false;
        for (var i = 0; i < newCard.length; i++) {
          if (newCard[i] == "&") {
            andUsed = true;
          }
        }
        if (andUsed) {
          //output error
          outputErrors(globals.errorEditFlashcard, globals.errorEditNoAnd);
          return;
        }

        //update current card
        setState(() {
          if (frontOfCard) {
            currentFileData[index * 2] = newCard;
          } else {
            currentFileData[index * 2 + 1] = newCard;
          }
        });

        //update prefs
        updatePrefs();
      } catch (e) {
        outputErrors(globals.errorEditFlashcard, e);
      }
    }

    void clickDeleteFlashcard(int index) {
      try {
        //show warning
        showDialog<String>(
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
                  //delete card
                  debugPrint('index=$index');
                  for (var i = 0; i < currentFileData.length; i++) {
                    debugPrint("currentFileData[$i]=${currentFileData[i]}");
                  }
                  setState(() {
                    currentFileData.removeAt(index * 2);
                    currentFileData.removeAt(index * 2);
                  });

                  //close dialogs
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  //update prefs
                  updatePrefs();

                  //update card amount
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  List<String> amountOfCards =
                      prefs.getStringList(globals.prefsFlashcardLength)!;
                  amountOfCards[currentFileNo] =
                      (int.parse(amountOfCards[currentFileNo]) - 1)
                          .toString();
                  prefs.setStringList(
                      globals.prefsFlashcardLength, amountOfCards);
                },
              )
            ],
          ),
        );
      } catch (e) {
        outputErrors(globals.errorEditDelete, e);
      }
    }

    void cardClicked(int index) {
      try {
        //set text of dialog
        controllerFront.text = currentFileData[index * 2];
        controllerRear.text = currentFileData[index * 2 + 1];

        //open cards dialog
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => SimpleDialog(
            title: Text(globals.editCardsCardNo + (index + 1).toString()),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(globals.defaultPadding),
                child: TextField(
                  decoration: const InputDecoration(hintText: globals.editCardsFront),
                  onChanged: (newCard) {
                    cardChanged(newCard, index, true);
                  },
                  controller: controllerFront,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(globals.defaultPadding),
                child: TextField(
                  decoration: const InputDecoration(hintText: globals.editCardsRear),
                  onChanged: (newCard) {
                    cardChanged(newCard, index, false);
                  },
                  controller: controllerRear,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text(globals.deleteFlashcards),
                onTap: () {
                  clickDeleteFlashcard(index);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text(globals.errorOk),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        );
      } catch (e) {
        outputErrors(globals.errorEditClicked, e);
      }
    }

    void titleChanged(String newTitle) async {
      try {
        //get shared prefs
        SharedPreferences prefs = await SharedPreferences.getInstance();

        //get titles list
        List<String> titlesList =
            prefs.getStringList(globals.prefsFlashcardTitles)!;

        //set titles list
        titlesList[currentFileNo] = newTitle;

        //save to prefs
        prefs.setStringList(globals.prefsFlashcardTitles, titlesList);
        globals.flashcardFiles = titlesList;
      } catch (e) {
        outputErrors(globals.errorEditTitle, e);
      }
    }

    void newCardAdded() async {
      try {
        //add new card
        setState(() {
          currentFileData.add(' ');
          currentFileData.add(' ');
        });

        //update prefs
        updatePrefs();

        //update card amount
        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> amountOfCards =
            prefs.getStringList(globals.prefsFlashcardLength)!;
        amountOfCards[currentFileNo] =
            (int.parse(amountOfCards[currentFileNo]) + 1).toString();
        prefs.setStringList(globals.prefsFlashcardLength, amountOfCards);

        //popup edit new card interface
        cardClicked(currentFileData.length ~/ 2 - 1);
      } catch (e) {
        outputErrors(globals.errorEditNewCard, e);
      }
    }

    //
    // LOAD INTERFACE
    //
    onLoad();
    return Builder(
      builder: (BuildContext context) => Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: globals.cardHeight,
              child: InkWell(
                splashColor: Theme.of(context).primaryColor,
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    const Text(
                      globals.paddingAsText + globals.editCardsFileName,
                      style: TextStyle(color: Color(0xFFFFFFFF)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(globals.defaultPadding),
                        child: TextField(
                          onChanged: titleChanged,
                          controller: controllerTitle,
                          style: const TextStyle(color: Color(0xFFFFFFFF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: SizedBox(
                height: globals.cardHeight,
                child: InkWell(
                  splashColor: Theme.of(context).primaryColor,
                  onTap: () {
                    newCardAdded();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(globals.paddingAsText + globals.editCardsAddCard),
                      Icon(Icons.add),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: DraggableScrollbar.arrows(
                controller: scrolly,
                child: ListView.builder(
                  controller: scrolly,
                  itemCount: currentFileData.length ~/ 2,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: SizedBox(
                        height: globals.cardHeight,
                        child: InkWell(
                          splashColor: Theme.of(context).primaryColor,
                          onTap: () {
                            cardClicked(index);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                globals.paddingAsText +
                                    currentFileData[index * 2],
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Divider(),
                              Text(
                                currentFileData[index * 2 + 1] +
                                    globals.paddingAsText,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
