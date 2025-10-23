import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../services/bluetooth_service.dart';
import 'dashboard.dart';

class BluetoothConnectionPage extends StatefulWidget {
  const BluetoothConnectionPage({super.key});

  @override
  State<BluetoothConnectionPage> createState() =>
      _BluetoothConnectionPageState();
}

class _BluetoothConnectionPageState extends State<BluetoothConnectionPage>
    with TickerProviderStateMixin {
  final BluetoothService _bluetoothService = BluetoothService();
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _bluetoothService.initialize();

    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _requestPermissionsAndScan();
  }

  Future<void> _requestPermissionsAndScan() async {
    bool hasPermission = await _bluetoothService.requestPermissions();
    if (hasPermission) {
      _scanForDevices();
    } else {
      _showPermissionDialog();
    }
  }

  Future<void> _scanForDevices() async {
    setState(() {
      _isScanning = true;
    });

    _scanController.forward();

    try {
      List<BluetoothDevice> devices =
          await _bluetoothService.getAvailableDevices();
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showErrorDialog('Failed to scan for devices: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
    });

    bool success = await _bluetoothService.connectToDevice(device);

    setState(() {
      _isConnecting = false;
    });

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      _showErrorDialog('Failed to connect to ${device.name}');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permissions Required'),
            content: const Text(
              'MediBuddy needs Bluetooth and Location permissions to connect to your health device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _requestPermissionsAndScan();
                },
                child: const Text('Grant Permissions'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.foodiBackground, AppTheme.primaryOrange],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Connect Device',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),

                const SizedBox(height: 40),

                // Bluetooth Icon with Animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: AppTheme.healthGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          FontAwesomeIcons.bluetooth,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Title and Description
                const Text(
                  'Connect Your Health Device',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Select your ESP32 health monitoring device from the list below',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                ),

                const SizedBox(height: 40),

                // Device List
                Expanded(child: _buildDeviceList()),

                const SizedBox(height: 20),

                // Scan Button
                AppTheme.createAnimatedButton(
                  text: _isScanning ? 'Scanning...' : 'Scan for Devices',
                  onPressed: _isScanning ? null : () => _scanForDevices(),
                  isLoading: _isScanning,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList() {
    if (_isScanning) {
      return _buildScanningIndicator();
    }

    if (_devices.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return _buildDeviceCard(device);
      },
    );
  }

  Widget _buildScanningIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _scanAnimation.value * 2 * 3.14159,
                child: const Icon(
                  FontAwesomeIcons.bluetooth,
                  size: 60,
                  color: AppTheme.primaryTeal,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Scanning for devices...',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.bluetooth,
            size: 60,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No devices found',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure your ESP32 device is powered on and in pairing mode',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BluetoothDevice device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppTheme.createGlassCard(
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryOrange, AppTheme.accentOrange],
                        ),
            ),
            child: const Icon(
              FontAwesomeIcons.heartPulse,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            device.name ?? 'Unknown Device',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Text(
            device.address,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          trailing:
              _isConnecting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.primaryOrange,
                    size: 16,
                  ),
          onTap: _isConnecting ? null : () => _connectToDevice(device),
        ),
      ),
    );
  }
}
