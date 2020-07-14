import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poker_table/Network/network.dart';
import 'package:poker_table/Objects/game.dart';

import 'game_page.dart';

class GamesListPage extends StatefulWidget {
  final List<Game> games;

  GamesListPage({Key key, @required this.games}) : super(key: key);

  @override
  _GamesListPageState createState() => _GamesListPageState(games: games);
}

class _GamesListPageState extends State<GamesListPage> {
  final List<Game> games;
  PokerApi _pokerApi;

  _GamesListPageState({Key key, @required this.games});

  @override
  void initState() {
    _pokerApi = PokerApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games'),
      ),
      body: ListView.builder(
          itemCount: widget.games.length,
          itemBuilder: (context, index) {
            final gameId = widget.games[index].id;

            return Dismissible(
              key: Key(gameId),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('${games[index].name} deleted')));

                setState(() {
                  games.removeAt(index);
                  _pokerApi.deleteGame(context, gameId);
                });
              },
              background: Container(color: Colors.red),
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.games[index].name),
                ),
                onTap: () => _pokerApi
                    .findGame(context, games[index])
                    .then((game) => _joinGame(game)),
              ),
            );
          }),
    );
  }

  _joinGame(Game game) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GamePage(game: game)));
  }
}
