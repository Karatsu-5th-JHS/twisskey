class ConvertUserInformation {
  final String id;
  final String name;
  final String username;
  final String avatarUrl;
  ConvertUserInformation(
      this.id,
      this.name,
      this.username,
      this.avatarUrl
      );

  ConvertUserInformation.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        username = json['username'],
        avatarUrl = json['avatarUrl'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'avatarUrl': avatarUrl
  };
}

class ConvertRenoteInformation {
  final String id;
  final String createdAt;
  final String userId;
  ConvertRenoteInformation(
      this.id,
      this.createdAt,
      this.userId
      );

  ConvertRenoteInformation.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = json["createdAt"],
        userId = json["userId"];

  Map<String, dynamic> toJson() => {
    'noteId': id,
    'createdAt': createdAt,
    'userId': userId
  };
}