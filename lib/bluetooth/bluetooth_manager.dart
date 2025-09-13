import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothManager {
  BluetoothConnection? connection;
  Function(Map<String, dynamic>)? onDataReceived;

  Future connectTo(
    String address, {
    required Function(Map<String, dynamic>) onData,
  }) async {
    connection = await BluetoothConnection.toAddress(address);
    onDataReceived = onData;
    connection!.input!.listen((Uint8List data) {
      try {
        final String msg = utf8.decode(data).trim();
        final Map<String, dynamic> jsonData = json.decode(msg);
        onDataReceived!(jsonData);
      } catch (e) {}
    });
  }

  void dispose() {
    connection?.dispose();
  }
}
