import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/health_data.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;
  StreamController<HealthData>? _healthDataController;
  StreamController<DeviceInfo>? _deviceInfoController;
  StreamController<bool>? _connectionStatusController;
  StreamController<String>? _errorController;

  bool _isConnected = false;
  String? _connectedDeviceName;
  Timer? _reconnectTimer;

  // Getters
  bool get isConnected => _isConnected;
  String? get connectedDeviceName => _connectedDeviceName;
  Stream<HealthData> get healthDataStream => _healthDataController!.stream;
  Stream<DeviceInfo> get deviceInfoStream => _deviceInfoController!.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController!.stream;
  Stream<String> get errorStream => _errorController!.stream;

  void initialize() {
    _healthDataController = StreamController<HealthData>.broadcast();
    _deviceInfoController = StreamController<DeviceInfo>.broadcast();
    _connectionStatusController = StreamController<bool>.broadcast();
    _errorController = StreamController<String>.broadcast();
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // First check if Bluetooth is enabled
      bool? isEnabled = await FlutterBluetoothSerial.instance.isOn;
      if (isEnabled != true) {
        await FlutterBluetoothSerial.instance.requestEnable();
        // Wait a bit for Bluetooth to enable
        await Future.delayed(const Duration(seconds: 2));
      }
      
      Map<Permission, PermissionStatus> permissions = await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ].request();
      
      return permissions.values.every((status) => status.isGranted);
    }
    return true;
  }

  Future<List<BluetoothDevice>> getAvailableDevices() async {
    try {
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      // Filter for ESP32 devices or show all if none found
      List<BluetoothDevice> esp32Devices = devices.where((device) => 
        device.name?.contains('ESP32') == true || 
        device.name?.contains('Health') == true ||
        device.name?.contains('MediBuddy') == true ||
        device.name?.contains('ESP32-Health-Pro') == true
      ).toList();
      
      // If no ESP32 devices found, show all devices
      return esp32Devices.isNotEmpty ? esp32Devices : devices;
    } catch (e) {
      _errorController?.add('Error scanning devices: $e');
      return [];
    }
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      if (_connection != null) {
        await disconnect();
      }

      _connection = await BluetoothConnection.toAddress(device.address);
      _isConnected = true;
      _connectedDeviceName = device.name ?? 'Unknown Device';
      
      _connectionStatusController?.add(true);
      _startListening();
      _startHeartbeat();
      
      return true;
    } catch (e) {
      _isConnected = false;
      _connectedDeviceName = null;
      _connectionStatusController?.add(false);
      _errorController?.add('Connection failed: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
      
      await _connection?.close();
      _connection = null;
      _isConnected = false;
      _connectedDeviceName = null;
      _connectionStatusController?.add(false);
    } catch (e) {
      _errorController?.add('Disconnect error: $e');
    }
  }

  void _startListening() {
    _connection?.input?.listen((data) {
      try {
        String message = utf8.decode(data);
        _processMessage(message);
      } catch (e) {
        _errorController?.add('Data parsing error: $e');
      }
    }, onError: (error) {
      _errorController?.add('Connection error: $error');
      _handleConnectionError();
    });
  }

  void _processMessage(String message) {
    try {
      // Clean the message
      message = message.trim();
      if (message.isEmpty) return;

      // Try to parse as JSON
      Map<String, dynamic> jsonData = json.decode(message);
      
      // Check if it's health data
      if (jsonData.containsKey('heartRate') && jsonData.containsKey('spo2')) {
        HealthData healthData = HealthData.fromJson(jsonData);
        _healthDataController?.add(healthData);
      }
      // Check if it's device info
      else if (jsonData.containsKey('device') && jsonData.containsKey('uptime')) {
        DeviceInfo deviceInfo = DeviceInfo.fromJson(jsonData);
        _deviceInfoController?.add(deviceInfo);
      }
    } catch (e) {
      // If JSON parsing fails, treat as plain text
      if (message.contains('heartRate') || message.contains('spo2')) {
        _errorController?.add('Invalid data format: $message');
      }
    }
  }

  void _startHeartbeat() {
    _reconnectTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _sendCommand('status');
      }
    });
  }

  void _handleConnectionError() {
    _isConnected = false;
    _connectedDeviceName = null;
    _connectionStatusController?.add(false);
    
    // Attempt to reconnect after 5 seconds
    Timer(Duration(seconds: 5), () {
      if (!_isConnected) {
        _errorController?.add('Connection lost. Attempting to reconnect...');
      }
    });
  }

  Future<void> _sendCommand(String command) async {
    if (_connection != null && _isConnected) {
      try {
        _connection!.output.add(utf8.encode('$command\n'));
        await _connection!.output.allSent;
      } catch (e) {
        _errorController?.add('Command send error: $e');
      }
    }
  }

  Future<void> requestStatus() async {
    await _sendCommand('status');
  }

  Future<void> requestSystemInfo() async {
    await _sendCommand('info');
  }

  Future<void> resetDevice() async {
    await _sendCommand('reset');
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _connection?.close();
    _healthDataController?.close();
    _deviceInfoController?.close();
    _connectionStatusController?.close();
    _errorController?.close();
  }
}