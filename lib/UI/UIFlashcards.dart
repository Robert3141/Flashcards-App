import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flashcards/globals.dart' as globals;
import 'package:flip_card/flip_card.dart';

class FlashcardsPage extends MaterialPageRoute<void> {
  FlashcardsPage(List<String> currentFileData)
      : super(builder: (BuildContext context) {
          //set variables for class
          List<String> cardFront = [""];
          List<String> cardRear = [""];
          double screenWidth = MediaQuery.of(context).size.width;
          ScrollController scrollControl = ScrollController();

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

          void newCard() {
            try {
              //cards ordered?
              if (globals.cardsOrdered) {
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
                Random rng = Random();
                int randomNumber = 0;
                int amountOfFlashcards = currentFileData.length ~/ 2;

                // make random flashcard as next in list
                randomNumber = rng.nextInt(amountOfFlashcards) * 2;
                cardFront[0] = currentFileData[randomNumber];
                cardRear[0] = currentFileData[randomNumber + 1];
                for (var i = 1; i < globals.amountOfCards; i++) {
                  randomNumber = rng.nextInt(amountOfFlashcards) * 2;
                  cardFront.add(currentFileData[randomNumber]);
                  cardRear.add(currentFileData[randomNumber + 1]);
                }
              }
            } catch (e) {
              outputErrors(globals.errorNewCard, e);
            }
          }

          //
          // LOAD INTERFACE
          //
          newCard();
          return Scaffold(
            appBar: AppBar(
              title: const Text(globals.tabTitleFlashcards),
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
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        }),
                        child: ListView.builder(
                          itemCount: cardFront
                              .length, //currentFileData.length ~/2 -1,
                          scrollDirection: Axis.horizontal,
                          controller: scrollControl,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return FlipCard(
                              //key: UniqueKey(),
                              direction: FlipDirection.HORIZONTAL,
                              speed: 1500,
                              front: InkWell(
                                child: Card(
                                  child: Container(
                                    width: screenWidth * globals.cardWidth,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              globals.defaultPadding),
                                          child: Text(cardFront[index]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              back: InkWell(
                                child: Card(
                                  child: Container(
                                    width: screenWidth * globals.cardWidth,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(
                                              globals.defaultPadding),
                                          child: Text(cardRear[index]),
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
