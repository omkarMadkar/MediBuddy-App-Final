import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../services/bluetooth_service.dart';
import '../models/health_data.dart';
import 'bluetooth_connection_page.dart';
import 'heart_disease_form.dart';
import 'ai_chat_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final BluetoothService _bluetoothService = BluetoothService();
  int _selectedIndex = 0;
  final List<HealthData> _healthHistory = [];
  bool _isConnected = false;
  final String _userName =
      "Hasan"; // Default name, can be fetched from user profile

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _bluetoothService.initialize();
    _setupBluetoothListeners();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _setupBluetoothListeners() {
    _bluetoothService.connectionStatusStream.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });

    _bluetoothService.healthDataStream.listen((healthData) {
      setState(() {
        _healthHistory.add(healthData);
        if (_healthHistory.length > 50) {
          _healthHistory.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.foodiBackground,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(),
          _buildConnectPage(),
          _buildPredictPage(),
          _buildProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            const SizedBox(height: 30),

            // Today's Information
            _buildTodaysInfo(),

            const SizedBox(height: 25),

            // Date Selector
            _buildDateSelector(),

            const SizedBox(height: 25),

            // New Challenge Card
            _buildChallengeCard(),

            const SizedBox(height: 25),

            // Health Metrics Grid
            _buildHealthMetricsGrid(),

            const SizedBox(height: 25),

            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Menu Button
        Container(
          width: 45,
          height: 45,
          decoration: AppTheme.foodiButtonDecoration,
          child: const Icon(Icons.menu, color: AppTheme.textPrimary, size: 22),
        ),

        const SizedBox(width: 20),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello $_userName,',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Text(
                'Ready for challenge?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // Profile Picture
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.primaryOrange, AppTheme.accentOrange],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildTodaysInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Today's Information", style: AppTheme.foodiTitleStyle),
        const SizedBox(height: 8),
        Text(
          _getCurrentDate(),
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final today = DateTime.now().weekday - 1; // Monday = 0

    return Row(
      children:
          days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isSelected = index == today;

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryOrange : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.foodiLightShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildChallengeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.foodiOrangeDecoration,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              FontAwesomeIcons.running,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Challenge',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'A 5000 Steps',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Health Metrics', style: AppTheme.foodiTitleStyle),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: FontAwesomeIcons.fire,
                title: 'Calories',
                value:
                    _healthHistory.isNotEmpty &&
                            _healthHistory.last.isValidHeartRate
                        ? '${(_healthHistory.last.heartRate * 0.5).toStringAsFixed(1)} kcal'
                        : '30.34 kcal',
                total: '400',
                progress: 0.076,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: FontAwesomeIcons.heart,
                title: 'Heart Rate',
                value:
                    _healthHistory.isNotEmpty &&
                            _healthHistory.last.isValidHeartRate
                        ? '${_healthHistory.last.heartRate} bpm'
                        : '109 bpm',
                subtitle: '15 minutes ago',
                color: AppTheme.errorRed,
                showGraph: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: FontAwesomeIcons.shoePrints,
                title: 'Steps',
                value: '1409 steps',
                total: '8,000',
                progress: 0.176,
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                icon: FontAwesomeIcons.weight,
                title: 'Weight',
                value: '56.5 kg',
                subtitle: 'Regular records',
                color: AppTheme.successGreen,
                showGraph: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    String? total,
    String? subtitle,
    required Color color,
    double? progress,
    bool showGraph = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.foodiCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTheme.foodiCardTitleStyle),
            ],
          ),
          const SizedBox(height: 12),
          if (showGraph)
            SizedBox(height: 40, child: _buildMiniGraph(color))
          else if (progress != null)
            Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
              ],
            ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (total != null)
            Text('of $total', style: AppTheme.foodiCardSubtitleStyle),
          if (subtitle != null)
            Text(subtitle, style: AppTheme.foodiCardSubtitleStyle),
        ],
      ),
    );
  }

  Widget _buildMiniGraph(Color color) {
    return CustomPaint(
      size: const Size(double.infinity, 40),
      painter: MiniGraphPainter(color: color),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: AppTheme.foodiTitleStyle),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: FontAwesomeIcons.bluetooth,
                title: 'Connect Device',
                subtitle: _isConnected ? 'Connected' : 'Not Connected',
                color:
                    _isConnected
                        ? AppTheme.successGreen
                        : AppTheme.textSecondary,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BluetoothConnectionPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: FontAwesomeIcons.stethoscope,
                title: 'Health Check',
                subtitle: 'Risk Assessment',
                color: AppTheme.primaryOrange,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HeartDiseaseFormPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.foodiCardDecoration,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTheme.foodiCardTitleStyle),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTheme.foodiCardSubtitleStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectPage() {
    return const BluetoothConnectionPage();
  }

  Widget _buildPredictPage() {
    return const HeartDiseaseFormPage();
  }

  Widget _buildProfilePage() {
    return const AIChatHelper();
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.homeCardShadow,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.bluetooth, 'Connect', 1),
              _buildNavItem(Icons.add, '', 2, isCenter: true),
              _buildNavItem(Icons.analytics, 'Predict', 3),
              _buildNavItem(FontAwesomeIcons.robot, 'AI Helper', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    bool isCenter = false,
  }) {
    final isSelected = _selectedIndex == index;

    if (isCenter) {
      return GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryOrange, AppTheme.accentTeal],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            );
          },
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? AppTheme.primaryOrange.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppTheme.primaryOrange : AppTheme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppTheme.primaryOrange : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class MiniGraphPainter extends CustomPainter {
  final Color color;

  MiniGraphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.3),
      Offset(size.width, size.height * 0.5),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
