import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flashcards/globals.dart' as globals;
import 'package:flip_card/flip_card.dart';

class FlashcardsPage extends MaterialPageRoute<Null> {

  FlashcardsPage(List<String> _currentFileData) : super(builder: (BuildContext context){

    //set variables for class
    List<String> _cardFront = [""];
    List<String> _cardRear = [""];
    double _screenWidth = MediaQuery.of(context).size.width;
    ScrollController _scrollControl = new ScrollController();

    //
    // FUNCTIONS
    //

    void outputErrors(String _error,_e){
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

    void newCard() {
      try {
        //cards ordered?
        if (globals.cardsOrdered){
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
          int _amountOfFlashcards = _currentFileData.length ~/ 2;

          // make random flashcard as next in list
          _randomNumber = _rng.nextInt(_amountOfFlashcards) * 2;
          _cardFront[0] = _currentFileData[_randomNumber];
          _cardRear[0] = _currentFileData[_randomNumber + 1];
          for (var i = 1; i < globals.amountOfCards; i++) {
            _randomNumber = _rng.nextInt(_amountOfFlashcards) * 2;
            _cardFront.add(_currentFileData[_randomNumber]);
            _cardRear.add(_currentFileData[_randomNumber + 1]);
          }

        }


      } catch(e) {
        outputErrors(globals.errorNewCard, e);
      }
    }

    //
    // LOAD INTERFACE
    //
    newCard();
    return Scaffold(
      appBar: AppBar(
        title: Text(globals.tabTitleFlashcards),
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
                  itemBuilder: (BuildContext context, int index) {
                    return FlipCard(
                      //key: UniqueKey(),
                      direction: FlipDirection.HORIZONTAL,
                      speed: 1500,
                      front: InkWell(
                        child: Card(
                          child: Container(
                            width: _screenWidth * globals.cardWidth,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8.0))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(globals.defaultPadding),
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
                            width: _screenWidth * globals.cardWidth,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(8.0))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(globals.defaultPadding),
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