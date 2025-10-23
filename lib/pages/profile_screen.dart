import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String _userName = "Hasan";
  final String _userEmail = "hasan@example.com";
  final int _age = 28;
  final String _gender = "Male";
  final double _height = 175.0; // cm
  final double _weight = 70.0; // kg

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.homeBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              const SizedBox(height: 30),

              // Profile Card
              _buildProfileCard(),

              const SizedBox(height: 30),

              // Health Stats
              _buildHealthStats(),

              const SizedBox(height: 30),

              // Menu Items
              _buildMenuItems(),

              const SizedBox(height: 30),

              // Settings
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 45,
            height: 45,
            decoration: AppTheme.homeButtonDecoration,
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF2C3E50),
              size: 22,
            ),
          ),
        ),

        const SizedBox(width: 20),

        const Text('Profile', style: AppTheme.homeTitleStyle),

        const Spacer(),

        GestureDetector(
          onTap: () {
            // Edit profile
          },
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit,
              color: AppTheme.primaryTeal,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.homeCardDecoration,
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.primaryTeal, AppTheme.accentTeal],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryTeal.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 50),
          ),

          const SizedBox(height: 20),

          // User Info
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _userEmail,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // User Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Age',
                  '$_age years',
                  FontAwesomeIcons.cake,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Gender',
                  _gender,
                  FontAwesomeIcons.venusMars,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Height',
                  '${_height.toInt()} cm',
                  FontAwesomeIcons.rulerVertical,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Weight',
                  '${_weight.toInt()} kg',
                  FontAwesomeIcons.weight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.homeBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryTeal, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Health Statistics', style: AppTheme.homeTitleStyle),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'BMI',
                '22.9',
                'Normal',
                const Color(0xFF27AE60),
                FontAwesomeIcons.chartLine,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Heart Rate',
                '72',
                'BPM',
                const Color(0xFFE74C3C),
                FontAwesomeIcons.heart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Steps Today',
                '8,432',
                'Steps',
                const Color(0xFF20B2AA),
                FontAwesomeIcons.shoePrints,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Calories',
                '1,250',
                'Burned',
                const Color(0xFFFF6B35),
                FontAwesomeIcons.fire,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.homeCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: AppTheme.homeCardTitleStyle),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(unit, style: AppTheme.homeCardSubtitleStyle),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Menu', style: AppTheme.homeTitleStyle),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: FontAwesomeIcons.chartBar,
          title: 'Health Reports',
          subtitle: 'View detailed health analytics',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: FontAwesomeIcons.bell,
          title: 'Notifications',
          subtitle: 'Manage your alerts',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: FontAwesomeIcons.clock,
          title: 'Activity History',
          subtitle: 'Track your progress over time',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: FontAwesomeIcons.share,
          title: 'Share Data',
          subtitle: 'Export your health data',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.homeCardDecoration,
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryTeal, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Settings', style: AppTheme.homeTitleStyle),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: FontAwesomeIcons.gear,
          title: 'App Settings',
          subtitle: 'Customize your experience',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: FontAwesomeIcons.shield,
          title: 'Privacy & Security',
          subtitle: 'Manage your data privacy',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: FontAwesomeIcons.questionCircle,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {},
        ),
        _buildMenuItem(
          icon: FontAwesomeIcons.infoCircle,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () {},
        ),
      ],
    );
  }
}
