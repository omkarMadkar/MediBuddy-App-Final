import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../services/bluetooth_service.dart';
import '../models/health_data.dart';
import '../components/health_card.dart';
import '../components/health_line_chart.dart';
import '../components/device_status_card.dart';
import 'heart_disease_form.dart';
import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final BluetoothService _bluetoothService = BluetoothService();
  final List<HealthData> _healthHistory = [];
  DeviceInfo? _deviceInfo;
  bool _isConnected = false;
  String? _connectedDeviceName;
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );

    _setupBluetoothListeners();
  }

  void _setupBluetoothListeners() {
    _bluetoothService.connectionStatusStream.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
        if (!isConnected) {
          _connectedDeviceName = null;
        }
      });
    });

    _bluetoothService.healthDataStream.listen((healthData) {
      setState(() {
        _healthHistory.add(healthData);
        // Keep only last 50 readings for performance
        if (_healthHistory.length > 50) {
          _healthHistory.removeAt(0);
        }
      });
    });

    _bluetoothService.deviceInfoStream.listen((deviceInfo) {
      setState(() {
        _deviceInfo = deviceInfo;
        _connectedDeviceName = deviceInfo.device;
      });
    });

    _bluetoothService.errorStream.listen((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppTheme.errorRed),
      );
    });
  }

  Future<void> _refreshData() async {
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });

    if (_isConnected) {
      await _bluetoothService.requestStatus();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.homeBackground, AppTheme.primaryTeal],
            stops: [0.0, 0.1],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 100,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'MediBuddy',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.homeBackground,
                            AppTheme.primaryTeal,
                          ],
                          stops: [0.0, 0.1],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: _refreshData,
                      icon: AnimatedBuilder(
                        animation: _refreshAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _refreshAnimation.value * 2 * 3.14159,
                            child: const Icon(
                              Icons.refresh,
                              color: AppTheme.textPrimary,
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.settings,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),

                // Device Status Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DeviceStatusCard(
                      isConnected: _isConnected,
                      deviceName: _connectedDeviceName ?? 'No Device',
                      batteryLevel: _deviceInfo?.uptime ?? 0,
                      lastSync:
                          _healthHistory.isNotEmpty
                              ? DateTime.fromMillisecondsSinceEpoch(
                                _healthHistory.last.timestamp,
                              )
                              : null,
                    ),
                  ),
                ),

                // Health Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: HealthCard(
                            title: 'Heart Rate',
                            value:
                                _healthHistory.isNotEmpty &&
                                        _healthHistory.last.isValidHeartRate
                                    ? _healthHistory.last.heartRate.toString()
                                    : '--',
                            unit: 'BPM',
                            icon: FontAwesomeIcons.heartPulse,
                            color: AppTheme.errorRed,
                            trend: _getHeartRateTrend(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: HealthCard(
                            title: 'SpO₂',
                            value:
                                _healthHistory.isNotEmpty &&
                                        _healthHistory.last.isValidSpO2
                                    ? _healthHistory.last.spo2.toString()
                                    : '--',
                            unit: '%',
                            icon: FontAwesomeIcons.droplet,
                            color: AppTheme.primaryBlue,
                            trend: _getSpO2Trend(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Charts Section
                if (_healthHistory.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: HealthLineChart(healthData: _healthHistory),
                    ),
                  ),

                // Disease Prediction Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildDiseasePredictionCard(),
                  ),
                ),

                // Bottom Spacing
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiseasePredictionCard() {
    return AppTheme.createGlassCard(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HeartDiseaseFormPage(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: AppTheme.healthGradient),
                    ),
                    child: const Icon(
                      FontAwesomeIcons.stethoscope,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Disease Prediction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Assess your heart disease risk',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.primaryTeal,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.chartLine,
                      color: AppTheme.primaryTeal,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Get instant risk assessment based on your health data',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getHeartRateTrend() {
    if (_healthHistory.length < 2) return 'stable';

    final recent =
        _healthHistory.length > 5
            ? _healthHistory
                .sublist(_healthHistory.length - 5)
                .where((data) => data.isValidHeartRate)
                .toList()
            : _healthHistory.where((data) => data.isValidHeartRate).toList();
    if (recent.length < 2) return 'stable';

    final avg =
        recent.map((data) => data.heartRate).reduce((a, b) => a + b) /
        recent.length;
    final latest = recent.last.heartRate;

    if (latest > avg + 5) return 'rising';
    if (latest < avg - 5) return 'falling';
    return 'stable';
  }

  String _getSpO2Trend() {
    if (_healthHistory.length < 2) return 'stable';

    final recent =
        _healthHistory.length > 5
            ? _healthHistory
                .sublist(_healthHistory.length - 5)
                .where((data) => data.isValidSpO2)
                .toList()
            : _healthHistory.where((data) => data.isValidSpO2).toList();
    if (recent.length < 2) return 'stable';

    final avg =
        recent.map((data) => data.spo2).reduce((a, b) => a + b) / recent.length;
    final latest = recent.last.spo2;

    if (latest > avg + 1) return 'rising';
    if (latest < avg - 1) return 'falling';
    return 'stable';
  }
}
