import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:poker_table/Objects/new_transaction.dart';
import 'package:poker_table/Objects/player.dart';
import 'package:poker_table/Objects/request.dart';
import 'package:poker_table/Objects/transaction_request.dart';

import '../Dialogs/loading_dialog.dart';
import '../Objects/game.dart';

class PokerApi {
  final String baseUrl = 'https://poker-board.herokuapp.com/api/v1/';

  Future<Game> createGame(BuildContext context, String name, int buyIn) async {
    LoadingDialog.showLoadingDialog(context);
    final response = await http.post(
      baseUrl + 'game',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{'name': name, 'buyIn': buyIn}),
    );

    Navigator.pop(context);

    if (response.statusCode == 201) {
      return Game.fromJson(json.decode(response.body));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to create game'),
              content: Text('Please try again'),
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

  Future<List<Game>> fetchGames(BuildContext context) async {
    LoadingDialog.showLoadingDialog(context);
    final response = await http.get(baseUrl);

    Navigator.pop(context);
    if (response.statusCode == 200) {
      return _parseGames(response.body);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to fetch games'),
              content: Text('Please try again'),
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

  List<Game> _parseGames(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Game>((json) => Game.fromJson(json)).toList();
  }

  Future<http.Response> deleteGame(BuildContext context, String gameId) async {
    final response =
        await http.delete(baseUrl + 'game/$gameId', headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 204) {
      return response;
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to delete game'),
              content: Text('Please try again'),
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

  Future<Game> findGame(BuildContext context, Game game) async {
    LoadingDialog.showLoadingDialog(context);
    final response = await http.get(baseUrl + '${game.id}');
    Navigator.pop(context);

    if (response.statusCode == 200) {
      return Game.fromJson(json.decode(response.body));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to join the game'),
              content: Text('Please try again'),
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

  Future<Game> deletePlayer(
      BuildContext context, Game game, String playerId, String name) async {
    var request = Request(type: 'remove', name: name, playerId: playerId);

    LoadingDialog.showLoadingDialog(context);
    final response = await http.post(
      baseUrl + 'players',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'gameId': game.id,
        'requests': [request.toJson()]
      }),
    );

    Navigator.pop(context);

    if (response.statusCode == 201) {
      return Game.fromJson(json.decode(response.body));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to delete the player $name'),
              content: Text('Please try again'),
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

  Future<Game> addPlayer(BuildContext context, Game game, String name) async {
    var request = Request(type: 'add', name: name);

    LoadingDialog.showLoadingDialog(context);
    final response = await http.post(
      baseUrl + 'players',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'gameId': game.id,
        'requests': [request.toJson()]
      }),
    );

    Navigator.pop(context);

    if (response.statusCode == 201) {
      return Game.fromJson(json.decode(response.body));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to add the player $name'),
              content: Text('Please try again'),
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

  Future<Game> addTransaction(BuildContext context, Game game,
      Player fromPlayer, Player toPlayer, int amount) async {
    var fromRequest = TransactionRequest(
        type: 'add',
        ownerId: fromPlayer.id,
        counterPartyId: toPlayer.id,
        description: toPlayer.name == 'Bank'
            ? 'Bank'
            : '${fromPlayer.name} loans to ${toPlayer.name}',
        amount: amount);
    var toRequest = TransactionRequest(
        type: 'add',
        ownerId: toPlayer.id,
        counterPartyId: fromPlayer.id,
        description: toPlayer.name == 'Bank'
            ? 'Bank'
            : '${toPlayer.name} borrows from ${fromPlayer.name}',
        amount: -amount);
    List<TransactionRequest> requests = [fromRequest];
    if (toPlayer.name != 'Bank') {
      requests.add(toRequest);
    }

    var transaction =
        NewTransaction(gameId: game.id, requests: requests).toJson();

    LoadingDialog.showLoadingDialog(context);
    final response = await http.post(
      baseUrl + 'transactions',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(transaction),
    );

    Navigator.pop(context);

    if (response.statusCode == 201) {
      return Game.fromJson(json.decode(response.body));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed to create transaction'),
              content: Text('Please try again'),
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
