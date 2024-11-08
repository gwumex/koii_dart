import 'dart:io';

import 'package:koii/koii.dart';

final devnetRpcUrl =
    Platform.environment['DEVNET_RPC_URL'] ?? 'http://127.0.0.1:8899';
final devnetWebsocketUrl =
    Platform.environment['DEVNET_WEBSOCKET_URL'] ?? 'ws://127.0.0.1:8900';

KoiiClient createTestKoiiClient() => KoiiClient(
      rpcUrl: Uri.parse(devnetRpcUrl),
      websocketUrl: Uri.parse(devnetWebsocketUrl),
    );
