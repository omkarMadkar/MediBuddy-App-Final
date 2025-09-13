import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class DeviceStatusCard extends StatefulWidget {
  final bool isConnected;
  final String deviceName;
  final int batteryLevel;
  final DateTime? lastSync;

  const DeviceStatusCard({
    super.key,
    required this.isConnected,
    required this.deviceName,
    required this.batteryLevel,
    this.lastSync,
  });

  @override
  State<DeviceStatusCard> createState() => _DeviceStatusCardState();
}

class _DeviceStatusCardState extends State<DeviceStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isConnected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(DeviceStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected != oldWidget.isConnected) {
      if (widget.isConnected) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme.createGlassCard(
      child: Column(
        children: [
          // Header
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isConnected ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: widget.isConnected
                              ? [AppTheme.successGreen, AppTheme.successGreen.withOpacity(0.8)]
                              : [AppTheme.errorRed, AppTheme.errorRed.withOpacity(0.8)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isConnected ? AppTheme.successGreen : AppTheme.errorRed)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isConnected ? FontAwesomeIcons.bluetooth : FontAwesomeIcons.bluetooth,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isConnected ? 'Device Connected' : 'Device Disconnected',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.isConnected ? AppTheme.successGreen : AppTheme.errorRed,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.deviceName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isConnected)
                Icon(
                  FontAwesomeIcons.signal,
                  color: AppTheme.successGreen,
                  size: 16,
                ),
            ],
          ),

          if (widget.isConnected) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.textSecondary, height: 1),
            const SizedBox(height: 16),

            // Device Info
            Row(
              children: [
                // Battery Level
                Expanded(
                  child: _buildInfoItem(
                    icon: FontAwesomeIcons.batteryHalf,
                    label: 'Battery',
                    value: '${_calculateBatteryPercentage()}%',
                    color: _getBatteryColor(),
                  ),
                ),
                const SizedBox(width: 16),
                // Last Sync
                Expanded(
                  child: _buildInfoItem(
                    icon: FontAwesomeIcons.clock,
                    label: 'Last Sync',
                    value: _getLastSyncText(),
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Uptime
            _buildInfoItem(
              icon: FontAwesomeIcons.stopwatch,
              label: 'Uptime',
              value: _formatUptime(widget.batteryLevel),
              color: AppTheme.primaryTeal,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _calculateBatteryPercentage() {
    // Simple calculation based on uptime (this is a placeholder)
    // In a real app, you'd get actual battery data from the device
    if (widget.batteryLevel > 3600) return 100; // 1 hour
    if (widget.batteryLevel > 1800) return 75;  // 30 minutes
    if (widget.batteryLevel > 900) return 50;   // 15 minutes
    if (widget.batteryLevel > 300) return 25;   // 5 minutes
    return 10;
  }

  Color _getBatteryColor() {
    final percentage = _calculateBatteryPercentage();
    if (percentage > 50) return AppTheme.successGreen;
    if (percentage > 25) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  String _getLastSyncText() {
    if (widget.lastSync == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(widget.lastSync!);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  String _formatUptime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}