import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'message.dart';
import 'client.dart';
import 'room.dart';

Middleware webSocketMiddleWare(Map<String, Room> rooms) {
  return createMiddleware(
    requestHandler: (req) {
      return req.url.path.startsWith('ws')
          ? webSocketHandler(
              (ws) async {
                // get user name from the url
                final userName = req.url.queryParameters['user'];
                final roomName = req.url.queryParameters['room'];

                // check if room exists
                if (!rooms.containsKey(roomName)) {
                  // assign
                  rooms[roomName] = Room.empty();
                }
                final room = rooms[roomName];
                final client = Client.fromAutoIdWebSocket(userName, ws);
                // notify client
                client.sendMessage(Message.create(
                  client.id,
                  client.name,
                  'first',
                  type: MessageType.first,
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
