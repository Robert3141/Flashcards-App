import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final cardHeight = 100.0;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards',
      theme: ThemeData(
        //app theme
        primarySwatch: Colors.blue,

      ),
      home: MyHomePage(title: 'Flashcards'),
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
  //set local variables
  int _currentTabIndex = 0;
  var _tabTitle = "Main";
  List<String> _flashcardFiles = ['a','b','c','d','e','f'];

  @override
  Widget build(BuildContext context) {

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
                          _flashcardFiles.add("test");
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("     Add new file!",overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold)),
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

                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('     '+_flashcardFiles[index],overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold)),
                                  Icon(Icons.content_copy)
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

      //Settings
      Container(
        child: Text("Settings"),
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
                _tabTitle = "Main";
                break;
              case 1:
                _tabTitle = "Settings";
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
