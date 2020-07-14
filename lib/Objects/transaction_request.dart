class TransactionRequest {
  final String type;
  final String ownerId;
  final String counterPartyId;
  final String description;
  final int amount;

  TransactionRequest(
      {this.type,
      this.ownerId,
      this.counterPartyId,
      this.description,
      this.amount});

  factory TransactionRequest.fromJson(Map<String, dynamic> json) {
    return TransactionRequest(
        type: json['type'],
        ownerId: json['ownerId'],
        counterPartyId: json['counterPartyId'],
        description: json['description'],
        amount: json['amount']);
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'ownerId': ownerId,
        'counterPartyId': counterPartyId,
        'description': description,
        'amount': amount
      };
}
