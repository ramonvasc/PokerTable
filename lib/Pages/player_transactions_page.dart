import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poker_table/Objects/player.dart';

class PlayerTransactionsPage extends StatelessWidget {
  final Player player;

  const PlayerTransactionsPage({Key key, @required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${player.name}\'s Transactions')),
      body: ListView.builder(
          itemCount: player.transactions.length != null
              ? player.transactions.length
              : 0,
          itemBuilder: (context, index) {
            final transactionId = player.transactions[index].id;

            return ListTile(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(player.transactions[index].description),
                    Text(player.transactions[index].amount.toString()),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
