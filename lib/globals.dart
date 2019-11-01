library flashcards.globals;

import 'package:flutter/material.dart';

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

//GLOBAL VARS
List<String> flashcardFiles = ['$exampleFileName'];
List<String> flashcardLengths = ['$exampleFileLength'];

//British strings:

//App Interface Main
const String appName = "Flashcards";
const String tabTitleMain = "Main";
const String tabTitleSettings = "Settings";
const String tabTitleFlashcards = "Flashcards";
const String tabTitleEditCards = "Edit Cards";
const String paddingAsText = "     ";

//Default cards
const String addNewCards = "Add New Flashcards";
const String newFileName = "New File";
const String exampleFileName = "Example File";
const String exampleFileLength = "3";
const String exampleFileData = "card1a&card1b&card2a&card2b&card3a&card3b&";

//Dialog Options
const String importFlashcards = "Import File";
const String openFlashcardsFile = "Open File";
const String createFlashcards = "Create New";
const String editFlashcards = "Edit";
const String loadFlashcards = "Load";
const String deleteFlashcards = "Delete";
const String errorOk = "OK";
const String errorCancel = "CANCEL";

//Shared prefs storage names
const String prefsFlashcardTitles = "Titles"; //Strings List
const String prefsFlashcardLength = "Amount"; //Strings List
const String prefsFlashcardData = "Data"; //Strings List
const String prefsAmountOfCards = "Number"; //Integer
const String prefsCardsOrdered = "Ordered"; //Boolean

//Settings Options
const String settingsCardsOrdered = "Order Cards";
const String settingsAmountOfCards = "Amount Of Cards (In shuffle)";
const String settingsDarkTheme = "Dark Theme";
const String settingsThemeColour = "Theme Colour (In Light Theme)";

//Edit Cards Options
const String editCardsFileName = "File name: ";
const String editCardsAddCard = "Add New Flashcard";
const String editCardsCardNo = "Card Number: ";
const String editCardsFront = "Front of Card";
const String editCardsRear = "Back of Card";
const String editDelete = "Deleting Card";
const String editDeleting = "Are you sure you want to delete this?";

//Error Messages
const String errorImport = "Error Importing Flashcards:\n";
const String errorNoFile = "The app did not receive the file.\n Are you sure you selected a file?";
const String errorNotSupported = "The file is not supported.\n Are you sure the .txt file is UTF-8?";
const String errorCreate = "Error Creating Flashcards:\n";
const String errorEdit = "Error Editing Flashcards:\n";
const String errorLoad = "Error Loading Flashcards:\n";
const String errorDelete = "Error Deleting Flashcards:\n";
const String errorNewCard = "Error Getting Next Flashcard:\n";
const String errorLoadPrefs = "Error Loading Settings:\n";
const String errorSettingsOrdered = "Error Changing Ordered Cards:\n";
const String errorSettingsAmount = "Error Changing Amount of Cards:\n";
const String errorSettingsDark = "Error Changing Dark Theme:\n";
const String errorSettingsTheme = "Error Changing Theme Colour:\n";
const String errorSplitString = "Internal Error:\n";
const String errorEditTitle = "Error Editing Title:\n";
const String errorEditNewCard = "Error Adding New Flashcard:\n";
const String errorEditFlashcard = "Error Editing Flashcard:\n";
const String errorEditNoAnd = "You used the '&' character. \n This cannot be used in this app unfortunately";
const String errorEditClicked = "Error displaying Flashcard Editor:\n";
const String errorEditPrefs = "Error Saving Changes:\n";
const String errorEditDelete = "Error Deleting Card:\n";