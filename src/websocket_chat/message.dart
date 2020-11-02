part of websocketchat;

enum MessageType { pong, user, info, error, unknown }

class Message {
  final String id;
  final String message;
  final DateTime timestamp;
  final String clientId;
  final String clientName;
  final MessageType type;

  const Message({
    this.id,
    this.message,
    this.timestamp,
    this.clientId,
    this.clientName,
    this.type,
  });

  factory Message.create(String clientId, String clientName, String message,
      {MessageType type = MessageType.user}) {
    return Message(
      id: Uuid().v1(),
      message: message,
      timestamp: DateTime.now(),
      clientId: clientId,
      clientName: clientName,
      type: type,
    );
  }

  factory Message.fromJsonString(String source) {
    final data = jsonDecode(source) as Map;
    return Message(
      id: data['id'],
      message: data['message'],
      timestamp: DateTime.parse(data['timestamp']),
      clientId: data['clientId'],
      clientName: data['clientName'],
      type: MessageTypeExtension.parse(data['type']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'clientId': clientId,
      'clientName': clientName,
      'type': type.stringify(),
    };
  }

  String toJson() => jsonEncode(toMap());
}

extension MessageTypeExtension on MessageType {
  static MessageType parse(String value) {
    switch (value) {
      case 'error':
        return MessageType.error;
      case 'info':
        return MessageType.info;
      case 'user':
        return MessageType.user;
      case 'pong':
        return MessageType.pong;
      default:
        return MessageType.unknown;
    }
  }

  String stringify() {
    switch (this) {
      case MessageType.error:
        return 'error';
      case MessageType.info:
        return 'info';
      case MessageType.user:
        return 'user';
      case MessageType.pong:
        return 'pong';
      default:
        return 'unknown';
    }
  }
}
