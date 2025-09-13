import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../services/bluetooth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final BluetoothService _bluetoothService = BluetoothService();
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _autoSyncEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundWhite,
              AppTheme.primaryTeal,
            ],
            stops: [0.0, 0.1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Device Settings
                      _buildSettingsSection(
                        title: 'Device Settings',
                        icon: FontAwesomeIcons.bluetooth,
                        children: [
                          _buildSettingsTile(
                            icon: FontAwesomeIcons.bluetooth,
                            title: 'Bluetooth Status',
                            subtitle: 'Manage device connection',
                            trailing: _buildConnectionStatus(),
                            onTap: () => _showBluetoothSettings(),
                          ),
                          _buildSettingsTile(
                            icon: FontAwesomeIcons.arrowsRotate,
                            title: 'Auto Sync',
                            subtitle: 'Automatically sync health data',
                            trailing: Switch(
                              value: _autoSyncEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _autoSyncEnabled = value;
                                });
                              },
                              activeColor: AppTheme.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // App Settings
                      _buildSettingsSection(
                        title: 'App Settings',
                        icon: FontAwesomeIcons.gear,
                        children: [
                          _buildSettingsTile(
                            icon: FontAwesomeIcons.moon,
                            title: 'Dark Mode',
                            subtitle: 'Switch to dark theme',
                            trailing: Switch(
                              value: _isDarkMode,
                              onChanged: (value) {
                                setState(() {
                                  _isDarkMode = value;
                                });
                              },
                              activeColor: AppTheme.primaryTeal,
                            ),
                          ),
                          _buildSettingsTile(
                            icon: FontAwesomeIcons.bell,
                            title: 'Notifications',
                            subtitle: 'Receive health alerts',
                            trailing: Switch(
                              value: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                              },
                              activeColor: AppTheme.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // About Section
                      _buildSettingsSection(
                        title: 'About',
                        icon: FontAwesomeIcons.infoCircle,
                        children: [
                          _buildSettingsTile(
                            icon: FontAwesomeIcons.heart,
                            title: 'About MediBuddy',
                            subtitle: 'Version 1.0.0',
                            onTap: () => _showAboutDialog(),
                          ),
                          _buildSettingsTile(
                            icon: FontAwesomeIcons.shield,
                            title: 'Privacy Policy',
                            subtitle: 'How we protect your data',
                            onTap: () => _showPrivacyDialog(),
                          ),
                          _buildSettingsTile(
                            icon: FontAwesomeIcons.questionCircle,
                            title: 'Help & Support',
                            subtitle: 'Get help and contact support',
                            onTap: () => _showSupportDialog(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          ),
          const Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return AppTheme.createGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryTeal,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryTeal.withOpacity(0.1),
                AppTheme.primaryTeal.withOpacity(0.05),
              ],
            ),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryTeal,
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: trailing ?? const Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.textSecondary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return StreamBuilder<bool>(
      stream: _bluetoothService.connectionStatusStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? false;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isConnected ? AppTheme.successGreen : AppTheme.errorRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isConnected ? 'Connected' : 'Disconnected',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  void _showBluetoothSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Settings'),
        content: const Text(
          'Manage your Bluetooth connection and device settings here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About MediBuddy'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('MediBuddy is your personal health monitoring companion.'),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Real-time health monitoring'),
            Text('• Heart disease risk assessment'),
            Text('• Beautiful, modern UI'),
            Text('• Bluetooth connectivity'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'MediBuddy is committed to protecting your privacy. All health data is stored locally on your device and is not shared with third parties without your explicit consent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Need help? Contact our support team or check our FAQ section for common questions and troubleshooting tips.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}