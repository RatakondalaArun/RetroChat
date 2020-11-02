# RetroChat

A realtime websocket chat application built using [Dart](https://dart.dev), [Shelf](https://pub.dev/packages/shelf), and JavaScript.

<image src="screenshots/retro-chat.gif" >

## How it Works?

| Class     | Usecase                            |
| --------- | ---------------------------------- |
| `Client`  | Represents a User or device.       |
| `Room`    | Represents a Chat or group.        |
| `Message` | Represents a message sent by user. |

`Client`(s) can join a `Room` and pass `Message` objects among them using websockets.
Each `Room` contains `Message`(s) which are stored in server memory and a self destruction timer (5 minutes) which gets triggered as soon as all `Client`(s) leave the `Room` and timer can be aborted if a `Client` rejoins the `Room` within 5 minutes.

## Requirments

- [Dart SDK](https://dart.dev/get-dart)
- Code Editor with dart plugins.

## Building and Running

1) Clone this repo using `git clone` or download this repo and extract it.

2) Download all dependencies in project root directory
   ```shell
   pub get
   ```

3) Use this command to start server
   ```shell
   dart src/main.dart
   ```

4) By default server will be running at `localhost:8080` and websocket at `localhost:8080/ws`. Now you can visit `localhost:8080` using a web browser.
