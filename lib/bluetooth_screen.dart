import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  BluetoothConnection? connection;
  bool isConnecting = false;
  bool get isConnected => connection != null && connection!.isConnected;
  String deviceAddress =
      ''; // set your ESP32 BT mac address or pick from devices
  Map<String, dynamic> sensorData = {};

  @override
  void initState() {
    super.initState();
    // Start Bluetooth connection
    _connect();
  }

  void _connect() async {
    setState(() => isConnecting = true);
    try {
      connection = await BluetoothConnection.toAddress(deviceAddress);
      setState(() => isConnecting = false);
      connection!.input!.listen(_onDataReceived).onDone(() {
        setState(() => connection = null);
      });
    } catch (e) {
      setState(() => isConnecting = false);
      print('Cannot connect, exception: $e');
    }
  }

  void _onDataReceived(Uint8List data) {
    // Assuming JSON strings sent by ESP32 are newline terminated
    String received = String.fromCharCodes(data).trim();
    try {
      var jsonData = json.decode(received);
      setState(() {
        sensorData = jsonData;
      });
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MediBuddy Bluetooth'),
        actions: [
          if (!isConnected && !isConnecting)
            IconButton(icon: Icon(Icons.refresh), onPressed: _connect),
          if (isConnecting)
            Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
      body: Center(
        child:
            isConnected
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Heart Rate: ${sensorData['heartRate'] ?? '--'} BPM',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'SpO₂: ${sensorData['spo2'] ?? '--'} %',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                )
                : Text('Device not connected'),
      ),
    );
  }
}
