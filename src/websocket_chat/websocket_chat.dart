library websocketchat;

import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'message.dart';
part 'client.dart';
part 'room.dart';

class WebSocketChat {
  final Map<String, Room> _rooms;

  const WebSocketChat._(this._rooms);

  factory WebSocketChat.create() {
    return WebSocketChat._({});
  }

  /// returns a websocket middleware
  Middleware get middleware {
    return createMiddleware(
      requestHandler: (req) {
        return req.url.path.startsWith('ws')
            ? webSocketHandler(
                (ws) async {
                  // get user name from the url
                  final userName = req.url.queryParameters['user'];
                  final roomName = req.url.queryParameters['room'];

                  final room = _handleRoomCreation(roomName);

                  final client = Client.fromAutoIdWebSocket(userName, ws);
                  // notify client
                  client.sendMessage(Message.create(
                    client.id,
                    client.name,
                    'first',
                    type: MessageType.pong,
                  ));

                  // add client to the rooom
                  await room.addClient(client);

                  // notify roommates
                  room.sendBrodCastMessage(
                    Message.create(
                      client.id,
                      client.name,
                      '${client.name} Joined',
                      type: MessageType.info,
                    ),
                  );
                },
              ).call(req)
            : null;
      },
    );
  }

  Room _handleRoomCreation(String roomName) {
    if (_rooms.containsKey(roomName)) {
      return _rooms[roomName];
    }

    return _rooms[roomName] = Room.create(roomName)
      ..onClientRemoved = (client) {
        print('Client removed name:${client.name}  id: ${client.id}');
      }
      ..onRoomDisposed = (id) {
        _rooms.remove(id);
        print('Room disposed id: $id');
      };
  }

  Future<void> dispose() async {
    try {
      await Future.forEach<Room>(
          _rooms.values, (room) async => await room.dispose());
    } catch (e) {
      print('Error while disposing ChatWebsocket');
      print(e);
    } finally {
      _rooms.clear();
    }
  }
}

Middleware webSocketMiddleWare(Map<String, Room> rooms) {
  return createMiddleware(
    requestHandler: (req) {
      return req.url.path.startsWith('ws')
          ? webSocketHandler(
              (ws) async {
                // get user name from the url
                final userName = req.url.queryParameters['user'];
                final roomName = req.url.queryParameters['room'];

                final room = _handleRoomCreation(roomName, rooms);

                final client = Client.fromAutoIdWebSocket(userName, ws);
                // notify client
                client.sendMessage(Message.create(
                  client.id,
                  client.name,
                  'pong',
                  type: MessageType.pong,
                ));

                // add client to the rooom
                await room.addClient(client);

                // notify roommates
                room.sendBrodCastMessage(
                  Message.create(
                    client.id,
                    client.name,
                    '${client.name} Joined',
                    type: MessageType.info,
                  ),
                );
              },
            ).call(req)
          : null;
    },
  );
}

// creates rome and
Room _handleRoomCreation(String roomName, Map<String, Room> rooms) {
  if (rooms.containsKey(roomName)) {
    return rooms[roomName];
  }

  return rooms[roomName] = Room.create(roomName)
    ..onClientRemoved = (client) {
      print('Client removed name:${client.name}  id: ${client.id}');
    }
    ..onRoomDisposed = (id) {
      rooms.remove(id);
      print('Room disposed id: $id');
    };
}
