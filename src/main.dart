import 'dart:io';

import 'package:shelf/shelf.dart' show Pipeline, logRequests;
import 'package:shelf/shelf_io.dart' show serve;
import 'package:shelf_virtual_directory/shelf_virtual_directory.dart';
import 'websocket_chat/websocket_chat.dart';

const SCRIPTS_PATH = '../web/script/';
const STYLES_PATH = '../web/style/';

void main() {
  try {
    final address = InternetAddress.anyIPv4;
    final port = int.parse(Platform.environment['PORT'] ?? '8080');
    final chatWebSocket = WebSocketChat.create();

    // web and static handler
    final webAndStaticFilesHandler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(chatWebSocket.middleware)
        .addHandler(ShelfVirtualDirectory('../public').handler);

    serve(webAndStaticFilesHandler, address, port)
        .then(
          (server) =>
              print('Serving at wss://${server.address.host}:${server.port}'),
        )
        .whenComplete(() async => await chatWebSocket.dispose());
  } catch (e) {
    print('Failed to create a server');
    print(e);
  }
}
