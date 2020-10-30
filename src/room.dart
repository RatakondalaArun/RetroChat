import 'package:uuid/uuid.dart';

import 'client.dart';
import 'message.dart';

class Room {
  final String _id;
  final Map<String, Client> _clients;
  final List<Message> _messages;

  String get id => _id;
  int get totalClients => _clients.length;
  List<Client> get clients => _clients.values.toList();
  List<Message> get messages => _messages;

  const Room._(
    this._id,
    this._clients,
    this._messages,
  );

  /// Creates a [Room] with a id and list of clients
  factory Room.create(String id, [List clients]) {
    return Room._(
      id,
      Map<String, Client>.fromIterable(
        clients ?? [],
        key: (client) => client.id,
        value: (client) => client,
      ),
      <Message>[],
    );
  }

  /// Creates a [Room] with uinque id and empty clientList
  factory Room.empty() {
    return Room.create(Uuid().v1(), <Client>[]);
  }

  Future<void> addClient(Client client) async {
    // check if client already exist
    if (_clients.containsKey(client.id)) {
      return;
    }
    // add client to room
    _clients[client.id] = client;
    // sends previous messages to client
    if (_messages.isNotEmpty) {
      _messages.forEach((m) => client.sendMessage(m));
    }

    // add client stream to room
    client.setUpStream(
      onEvent: (message) {
        sendBrodCastMessage(message);
        _messages.add(message);
      },
      onClosed: (client) {
        removeClient(client.id);
        print('Disconnected client ${client.id} name: ${client.name}');
      },
    );
  }

  // checks if client already exists
  bool isClientExist(String id) => _clients.containsKey(id);

  // finds and returns client
  Client findClient(String id) =>
      _clients.containsKey(id) ? _clients[id] : null;

  // removes client from the
  void removeClient(String id) {
    if (_clients.containsKey(id)) {
      _clients.remove(id);
      if (_clients.isEmpty) {
        dispose();
      }
    }
  }

  // sends messages to all clients in the room
  void sendBrodCastMessage(Message message) {
    _clients.values.forEach((client) => client.sendMessage(message));
  }

  Future<void> dispose() {
    print('Disposing room = $this');
    return Future.value();
  }

  @override
  String toString() {
    return '''
Room(
  id: $_id,
  totalClients: $totalClients
)    
    ''';
  }
}
