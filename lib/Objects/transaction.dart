class Transaction {
  final String id;
  final String refId;
  final String ownerId;
  final String counterPartyId;
  final String description;
  final int amount;
  final String createdAt;

  Transaction(
      {this.id,
      this.refId,
      this.ownerId,
      this.counterPartyId,
      this.description,
      this.amount,
      this.createdAt});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
        id: json['_id'],
        refId: json['refId'],
        ownerId: json['ownerId'],
        counterPartyId: json['counterPartyId'],
        description: json['description'],
        amount: json['amount'],
        createdAt: json['createdAt']);
  }
}
