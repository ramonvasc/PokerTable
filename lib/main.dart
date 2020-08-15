import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stetho/flutter_stetho.dart';
import 'package:poker_table/Network/network.dart';
import 'package:poker_table/Pages/game_list_page.dart';

import 'Pages/game_page.dart';

void main() {
  if (!kReleaseMode) {
    // Network requests debugger
    Stetho.initialize();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Find a game or create a game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController gameNameTextController;
  TextEditingController buyInTextController;
  TextEditingController gameIdTextController;
  PokerApi _pokerApi;

  @override
  void dispose() {
    gameNameTextController.dispose();
    buyInTextController.dispose();
    gameIdTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    gameNameTextController = TextEditingController();
    buyInTextController = TextEditingController();
    gameIdTextController = TextEditingController();
    _pokerApi = PokerApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Poker Board'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: _findGames,
              child: Text('Find Games'),
            ),
            RaisedButton(
              onPressed: _createGame,
              child: Text('Create Game'),
            )
          ],
        ),
      ),
    );
  }

  void _findGames() async {
    _pokerApi.fetchGames(context).then((games) => Navigator.push(context,
        MaterialPageRoute(builder: (context) => GamesListPage(games: games))));
  }

  void _createGame() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text("Create a new poker game."),
            content: Container(
              height: 120,
              child: Column(
                children: <Widget>[
                  TextField(
                    autofocus: true,
                    controller: gameNameTextController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'eg. Herttoniemi Poker',
                    ),
                  ),
                  TextField(
                    autofocus: false,
                    controller: buyInTextController,
                    decoration: InputDecoration(
                      labelText: 'Buy In',
                      hintText: 'eg. 40',
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text("Create"),
                onPressed: () {
                  setState(() {
                    if (!gameNameTextController.text.isEmpty &&
                        !buyInTextController.text.isEmpty) {
                      _pokerApi
                          .createGame(context, gameNameTextController.text,
                              int.parse(buyInTextController.text))
                          .then((game) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          GamePage(game: game)))
                              .then((result) => Navigator.of(context).pop()));
                      setState(() {
                        gameNameTextController.clear();
                        buyInTextController.clear();
                      });
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('You have to input both values'),
                              actions: <Widget>[
                                FlatButton(
                                  child: new Text("Ok"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    }
                  });
                },
              ),
            ],
          );
        });
  }
}
