import 'dart:convert';

List<UserModal> userModalFromJson(String str) => List<UserModal>.from(json.decode(str).map((x) => UserModal.fromJson(x)));

String userModalToJson(List<UserModal> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserModal {
  UserModal({
    this.sender,
    this.text,
    this.timestamp,
    this.type,
    this.isMe,
  });

  String? sender;
  String? text;
  DateTime? timestamp;
  String? type;
  bool? isMe;

  factory UserModal.fromJson(Map  json) => UserModal(
      sender: json["sender"],
      text: json["text"],
      timestamp: json["timestamp"],
      type: json["type"],
      isMe: json["isMe"],
  );

  Map<String, dynamic> toJson() => {
    "sender": sender,
    "text": text,
    "timestamp": timestamp,
    "type": type,
    "isMe": isMe
  };
}
