import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poker_table/Network/network.dart';
import 'package:poker_table/Objects/game.dart';
import 'package:poker_table/Objects/player.dart';
import 'package:poker_table/Pages/player_transactions_page.dart';

class GamePage extends StatefulWidget {
  final Game game;

  GamePage({Key key, @required this.game}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState(game: game);
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  AnimationController _animationController;
  TextEditingController _playerNameTextController;
  TextEditingController _amountTextController;
  PokerApi _pokerApi;
  Game game;

  _GamePageState({Key key, @required this.game});

  static const List<IconData> icons = const [
    Icons.equalizer,
    Icons.person,
    Icons.attach_money
  ];

  @override
  void dispose() {
    _animationController.dispose();
    _playerNameTextController.dispose();
    _amountTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _playerNameTextController = TextEditingController();
    _amountTextController = TextEditingController();
    _pokerApi = PokerApi();
    _animationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).accentColor;
    return Scaffold(
      appBar: AppBar(
          title: Text(game.name.toString() + ' : €' + game.buyIn.toString())),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Player',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      'Balance',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount:
                    game.players.length != null ? game.players.length : 0,
                itemBuilder: (context, index) {
                  final playerId = game.players[index].id;

                  return Dismissible(
                    key: Key(playerId),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) {
                      if (game.players[index].balance == 0) {
                        return Future<bool>.value(true);
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                    'You can\'t delete players with a balance larger or smaller than 0.'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: new Text("Ok"),
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    onDismissed: (direction) {
                      String playerName = game.players[index].name;
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('${playerName} deleted')));

                      setState(() {
                        game.players.removeAt(index);
                        _pokerApi.deletePlayer(
                            context, game, playerId, playerName);
                      });
                    },
                    background: Container(color: Colors.red),
                    child: ListTile(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlayerTransactionsPage(
                                  player: game.players[index]))),
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(game.players[index].name),
                            Text(game.players[index].balance.toString()),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: new Column(
        mainAxisSize: MainAxisSize.min,
        children: new List.generate(icons.length, (int index) {
          Widget child = new Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: new ScaleTransition(
              scale: new CurvedAnimation(
                parent: _animationController,
                curve: new Interval(0.0, 1.0 - index / icons.length / 2.0,
                    curve: Curves.easeOut),
              ),
              child: new FloatingActionButton(
                heroTag: null,
                backgroundColor: backgroundColor,
                mini: true,
                child: new Icon(icons[index], color: foregroundColor),
                onPressed: () {
                  switch (index) {
                    case 0:
                      _checkTotalBalance();
                      break;
                    case 1:
                      _getNewPlayer();
                      break;
                    default:
                      _getNewTransaction();
                      break;
                  }
                },
              ),
            ),
          );
          return child;
        }).toList()
          ..add(
            new FloatingActionButton(
              heroTag: null,
              child: new AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget child) {
                  return new Transform(
                    transform: new Matrix4.rotationZ(
                        _animationController.value * 0.5 * math.pi),
                    alignment: FractionalOffset.center,
                    child: new Icon(_animationController.isDismissed
                        ? Icons.add
                        : Icons.close),
                  );
                },
              ),
              onPressed: () {
                if (_animationController.isDismissed) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
            ),
          ),
      ),
    );
  }

  void _getNewPlayer() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text("Add a new player to the game."),
            content: TextField(
              autofocus: true,
              controller: _playerNameTextController,
              decoration: InputDecoration(
                labelText: 'Player Name',
                hintText: 'eg. John Doe',
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
                child: new Text("Add"),
                onPressed: () {
                  if (!_playerNameTextController.text.isEmpty) {
                    _pokerApi
                        .addPlayer(
                            context, game, _playerNameTextController.text)
                        .then((updatedGame) => {
                              setState(() {
                                _playerNameTextController.clear();
                                game = updatedGame;
                              }),
                              Navigator.of(context).pop(),
                            });
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('You have to give a name!'),
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
                },
              ),
            ],
          );
        });
  }

  _updateGameState(Game newGame) {
    setState(() {
      game = newGame;
    });
  }

  void _getNewTransaction() {
    showDialog(
        context: context,
        builder: (context) {
          Player _selectedFromPlayer;
          Player _selectedToPlayer;
          List<Player> _playersWithBank = game.players;
          _playersWithBank.add(Player(name: 'Bank'));
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Add a new transaction to the game."),
                content: Container(
                  height: 160,
                  child: Column(
                    children: <Widget>[
                      TextField(
                        autofocus: true,
                        controller: _amountTextController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          hintText: 'eg. 40',
                        ),
                      ),
                      DropdownButton<Player>(
                        hint: _selectedFromPlayer != null
                            ? Text('From: ${_selectedFromPlayer.name}')
                            : Text('From: '),
                        underline: SizedBox(),
                        items: game.players.map((Player player) {
                          return DropdownMenuItem<Player>(
                            value: player,
                            child: Text(
                              player.name,
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        onChanged: (Player selectedFromPlayer) {
                          setState(() {
                            _selectedFromPlayer = selectedFromPlayer;
                          });
                        },
                      ),
                      DropdownButton<Player>(
                        hint: _selectedToPlayer != null
                            ? Text('To: ${_selectedToPlayer.name}')
                            : Text('To: '),
                        underline: SizedBox(),
                        items: _playersWithBank.map((Player player) {
                          return DropdownMenuItem<Player>(
                            value: player,
                            child: Text(
                              player.name,
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        onChanged: (Player selectedToPlayer) {
                          setState(() {
                            _selectedToPlayer = selectedToPlayer;
                          });
                        },
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
                    child: new Text("Add"),
                    onPressed: () {
                      if (_selectedFromPlayer != _selectedToPlayer) {
                        _pokerApi
                            .addTransaction(
                                context,
                                game,
                                _selectedFromPlayer,
                                _selectedToPlayer,
                                _amountTextController.text.isNotEmpty
                                    ? int.parse('${_amountTextController.text}')
                                    : game.buyIn)
                            .then((updatedGame) => {
                                  Navigator.of(context).pop(),
                                  _updateGameState(updatedGame),
                                });
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title:
                                    Text('You can\'t select the same player'),
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
                    },
                  ),
                ],
              );
            },
          );
        });
  }

  void _checkTotalBalance() {
    double totalBalance = 0;
    game.players.forEach((player) {
      totalBalance += player.balance;
    });

    if (totalBalance != 0) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  Text('Total balance is not zero! Balance is $totalBalance'),
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
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Total balance is zero!'),
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
  }
}
