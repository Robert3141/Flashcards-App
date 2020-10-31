import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flashcards/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

class EditCardsPage extends MaterialPageRoute<Null> {
  EditCardsPage(List<String> _currentFileData, int _currentFileNo)
      : super(builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(globals.tabTitleEditCards),
              elevation: 1.0,
            ),
            body: Builder(
              builder: (BuildContext context) => EditCards(
                  currentFileData: _currentFileData,
                  currentFileNo: _currentFileNo),
            ),
          );
        });
}

class EditCards extends StatefulWidget {
  EditCards(
      {@required this.currentFileData,
      @required this.currentFileNo,
      Key key,
      int index})
      : super(key: key);

  final List<String> currentFileData;
  final int currentFileNo;

  static const String routeName = "/EditCards";

  @override
  EditCardsState createState() => new EditCardsState();
}

class EditCardsState extends State<EditCards> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // LOCAL VARS
    final _controllerFront = TextEditingController();
    final _controllerRear = TextEditingController();
    final _controllerTitle = TextEditingController();
    List<String> _currentFileData = widget.currentFileData;
    int _currentFileNo = widget.currentFileNo;
    ScrollController _scrolly = ScrollController();

    //
    // FUNCTIONS
    //

    void outputErrors(String _error, _e) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(_error),
          content: Text(_e.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text(globals.errorOk),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    }

    void _onLoad() async {
      try {
        //get shared prefs
        SharedPreferences _prefs = await SharedPreferences.getInstance();

        //get title
        _controllerTitle.text =
            _prefs.getStringList(globals.prefsFlashcardTitles)[_currentFileNo];
      } catch (e) {
        outputErrors(globals.errorLoadPrefs, e);
      }
    }

    void _updatePrefs() async {
      try {
        //local vars
        String _currentFileDataString = "";

        //compress string to list
        for (var i = 0; i < _currentFileData.length; i++) {
          _currentFileDataString += _currentFileData[i] + "&";
        }

        //load prefs
        SharedPreferences _prefs = await SharedPreferences.getInstance();

        //get string list
        List<String> _currentFlashcardData =
            _prefs.getStringList(globals.prefsFlashcardData);

        //update string list
        _currentFlashcardData[_currentFileNo] = _currentFileDataString;

        //save to prefs
        _prefs.setStringList(globals.prefsFlashcardData, _currentFlashcardData);
      } catch (e) {
        outputErrors(globals.errorEditPrefs, e);
      }
    }

    void _cardChanged(String _newCard, int _index, bool _frontOfCard) async {
      try {
        //check first that & not used
        bool andUsed = false;
        for (var i = 0; i < _newCard.length; i++) {
          if (_newCard[i] == "&") {
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
          if (_frontOfCard) {
            _currentFileData[_index * 2] = _newCard;
          } else {
            _currentFileData[_index * 2 + 1] = _newCard;
          }
        });

        //update prefs
        _updatePrefs();
      } catch (e) {
        outputErrors(globals.errorEditFlashcard, e);
      }
    }

    void _clickDeleteFlashcard(int _index) {
      try {
        //show warning
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(globals.editDelete),
            content: Text(globals.editDeleting),
            actions: <Widget>[
              FlatButton(
                child: Text(globals.errorCancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(globals.errorOk),
                onPressed: () async {
                  //delete card
                  debugPrint('_index=$_index');
                  for (var i = 0; i < _currentFileData.length; i++) {
                    debugPrint("_currentFileData[$i]=" + _currentFileData[i]);
                  }
                  setState(() {
                    _currentFileData.removeAt(_index * 2);
                    _currentFileData.removeAt(_index * 2);
                  });

                  //close dialogs
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  //update prefs
                  _updatePrefs();

                  //update card amount
                  SharedPreferences _prefs =
                      await SharedPreferences.getInstance();
                  List<String> _amountOfCards =
                      _prefs.getStringList(globals.prefsFlashcardLength);
                  _amountOfCards[_currentFileNo] =
                      (int.parse(_amountOfCards[_currentFileNo]) - 1)
                          .toString();
                  _prefs.setStringList(
                      globals.prefsFlashcardLength, _amountOfCards);
                },
              )
            ],
          ),
        );
      } catch (e) {
        outputErrors(globals.errorEditDelete, e);
      }
    }

    void _cardClicked(int index) {
      try {
        //set text of dialog
        _controllerFront.text = _currentFileData[index * 2];
        _controllerRear.text = _currentFileData[index * 2 + 1];

        //open cards dialog
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => SimpleDialog(
            title: Text(globals.editCardsCardNo + (index + 1).toString()),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(globals.defaultPadding),
                child: TextField(
                  decoration: InputDecoration(hintText: globals.editCardsFront),
                  onChanged: (_newCard) {
                    _cardChanged(_newCard, index, true);
                  },
                  controller: _controllerFront,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(globals.defaultPadding),
                child: TextField(
                  decoration: InputDecoration(hintText: globals.editCardsRear),
                  onChanged: (_newCard) {
                    _cardChanged(_newCard, index, false);
                  },
                  controller: _controllerRear,
                ),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever),
                title: Text(globals.deleteFlashcards),
                onTap: () {
                  _clickDeleteFlashcard(index);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text(globals.errorOk),
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

    void _titleChanged(String _newTitle) async {
      try {
        //get shared prefs
        SharedPreferences _prefs = await SharedPreferences.getInstance();

        //get titles list
        List<String> _titlesList =
            _prefs.getStringList(globals.prefsFlashcardTitles);

        //set titles list
        _titlesList[_currentFileNo] = _newTitle;

        //save to prefs
        _prefs.setStringList(globals.prefsFlashcardTitles, _titlesList);
        globals.flashcardFiles = _titlesList;
      } catch (e) {
        outputErrors(globals.errorEditTitle, e);
      }
    }

    void _newCardAdded() async {
      try {
        //add new card
        setState(() {
          _currentFileData.add(' ');
          _currentFileData.add(' ');
        });

        //update prefs
        _updatePrefs();

        //update card amount
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        List<String> _amountOfCards =
            _prefs.getStringList(globals.prefsFlashcardLength);
        _amountOfCards[_currentFileNo] =
            (int.parse(_amountOfCards[_currentFileNo]) + 1).toString();
        _prefs.setStringList(globals.prefsFlashcardLength, _amountOfCards);

        //popup edit new card interface
        _cardClicked(_currentFileData.length ~/ 2 - 1);
      } catch (e) {
        outputErrors(globals.errorEditNewCard, e);
      }
    }

    //
    // LOAD INTERFACE
    //
    _onLoad();
    return new Builder(
      builder: (BuildContext context) => Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: globals.cardHeight,
              child: InkWell(
                splashColor: Theme.of(context).primaryColor,
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      globals.paddingAsText + globals.editCardsFileName,
                      style: TextStyle(color: Color(0xFFFFFFFF)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(globals.defaultPadding),
                        child: TextField(
                          onChanged: _titleChanged,
                          controller: _controllerTitle,
                          style: TextStyle(color: Color(0xFFFFFFFF)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Container(
                height: globals.cardHeight,
                child: InkWell(
                  splashColor: Theme.of(context).primaryColor,
                  onTap: () {
                    _newCardAdded();
                  },
                  child: Row(
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
                controller: _scrolly,
                child: ListView.builder(
                  controller: _scrolly,
                  itemCount: _currentFileData.length ~/ 2,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: Container(
                        height: globals.cardHeight,
                        child: InkWell(
                          splashColor: Theme.of(context).primaryColor,
                          onTap: () {
                            _cardClicked(index);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                globals.paddingAsText +
                                    _currentFileData[index * 2],
                                overflow: TextOverflow.ellipsis,
                              ),
                              Divider(),
                              Text(
                                _currentFileData[index * 2 + 1] +
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
