class Request {
  final String type;
  final String playerId;
  final String name;

  Request({this.type, this.playerId, this.name});

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      type: json['type'],
      playerId: json['playerId'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'type': type, 'playerId': playerId, 'name': name};
}
