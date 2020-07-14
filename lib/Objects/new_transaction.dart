import 'package:poker_table/Objects/transaction_request.dart';

class NewTransaction {
  final String gameId;
  final List<TransactionRequest> requests;

  NewTransaction({this.gameId, this.requests});

  factory NewTransaction.fromJson(Map<String, dynamic> json) {
    var requestsList = json['requests'] as List ?? [];

    return NewTransaction(
      gameId: json['gameId'],
      requests: requestsList.map((index) => TransactionRequest.fromJson(index)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() =>
      {'gameId': gameId, 'requests': requests};
}
