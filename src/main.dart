import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart' show Pipeline, logRequests;
import 'package:shelf/shelf_io.dart' show serve;
import 'package:shelf_virtual_directory/shelf_virtual_directory.dart';
import 'room.dart';
import 'websocket.dart';

const SCRIPTS_PATH = '../web/script/';
const STYLES_PATH = '../web/style/';

final rooms = <String, Room>{};

void main() {
  try {
    final address = InternetAddress.anyIPv4;
    final port = int.parse(Platform.environment['PORT'] ?? '8080');

    // web and static handler
    final webAndStaticFilesHandler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(webSocketMiddleWare(rooms))
        .addHandler(ShelfVirtualDirectory('../web').handler);

    serve(webAndStaticFilesHandler, address, port)
        .then(
          (server) =>
              print('Serving at ws://${server.address.host}:${server.port}'),
        )
        .whenComplete(
          () => rooms.values.forEach((room) async => await room.dispose()),
        );
  } catch (e) {
    print('Failed to create a server');
    print(e);
  }
}
