import 'package:poker_table/Objects/player.dart';

class Game {
  final String id;
  final String name;
  final int buyIn;
  final List<Player> players;
  final String updatedAt;
  final String createdAt;

  Game(
      {this.id,
      this.name,
      this.buyIn,
      this.players,
      this.updatedAt,
      this.createdAt});

  factory Game.fromJson(Map<String, dynamic> json) {
    var playersList = json['players'] as List ?? [];

    return Game(
        id: json['_id'],
        name: json['name'],
        buyIn: json['buyIn'],
        players:
            playersList.map((index) => Player.fromJson(index)).toList() ?? [],
        updatedAt: json['updatedAt'],
        createdAt: json['createdAt']);
  }
}
