import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'message.dart';

class Client {
  final String _id;
  final String _name;
  final WebSocketChannel _channel;

  String get id => _id;
  String get name => _name;
  Stream get stream => _channel.stream;

  const Client._(this._id, this._name, this._channel);

  factory Client.fromAutoIdWebSocket(
      String name, WebSocketChannel webSocketChannel) {
    return Client._(Uuid().v1(), name, webSocketChannel);
  }

  factory Client.fromIdAndWebSocket(
    String id,
    String name,
    WebSocketChannel webSocketChannel,
  ) {
    return Client._(id, name, webSocketChannel);
  }

  void sendMessage(Message message) {
    _channel.sink.add(message.toJson());
  }

  void setUpStream({
    void Function(Message event) onEvent,
    void Function(Client client) onClosed,
  }) {
    _channel.stream.asBroadcastStream().listen(
      (event) => onEvent?.call(Message(
        id: Uuid().v1(),
        clientId: _id,
        message: (jsonDecode(event) as Map)['message'],
        timestamp: DateTime.now(),
        clientName: _name,
        type: MessageType.user,
      )),
      onDone: () async {
        await closeConnection();
        onClosed?.call(this);
      },
    );
  }

  Future<void> closeConnection() => _channel.sink.close();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': _id,
      'name': _name,
    };
  }
}
