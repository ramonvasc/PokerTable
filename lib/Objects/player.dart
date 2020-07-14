import 'package:poker_table/Objects/transaction.dart';

class Player {
  final String id;
  final String name;
  final List<Transaction> transactions;
  final int balance;
  final String createdAt;

  Player({this.id, this.name, this.transactions, this.balance, this.createdAt});

  factory Player.fromJson(Map<String, dynamic> json) {
    var transactionsList = json['transactions'] as List ?? [];

    return Player(
        id: json['_id'],
        name: json['name'],
        transactions: transactionsList
                .map((index) => Transaction.fromJson(index))
                .toList() ??
            [],
        balance: json['balance'],
        createdAt: json['createdAt']);
  }
}
