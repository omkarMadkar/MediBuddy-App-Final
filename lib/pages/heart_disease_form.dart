import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../models/prediction_data.dart';
import 'prediction_result_page.dart';

class HeartDiseaseFormPage extends StatefulWidget {
  const HeartDiseaseFormPage({super.key});

  @override
  State<HeartDiseaseFormPage> createState() => _HeartDiseaseFormPageState();
}

class _HeartDiseaseFormPageState extends State<HeartDiseaseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Form data
  int _age = 30;
  String _gender = 'Male';
  int _smoking = 0;
  int _diabetes = 0;
  int _chestPain = 0;
  int _bloodPressure = 120;
  int _cholesterol = 200;
  int _hdl = 50;
  int _ldl = 100;
  int _triglycerides = 150;
  int _fastingGlucose = 100;
  int _heartRate = 70;
  int _spo2 = 98;

  final List<String> _pages = [
    'Personal Info',
    'Health Metrics',
    'Risk Factors',
    'Review & Predict',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitForm();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    final formData = PredictionForm(
      age: _age,
      gender: _gender,
      smoking: _smoking,
      diabetes: _diabetes,
      chestPain: _chestPain,
      bloodPressure: _bloodPressure,
      cholesterol: _cholesterol,
      hdl: _hdl,
      ldl: _ldl,
      triglycerides: _triglycerides,
      fastingGlucose: _fastingGlucose,
      heartRate: _heartRate,
      spo2: _spo2,
    );

    final result = PredictionResult.calculateRisk(formData.toMLInput());

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) =>
                  PredictionResultPage(result: result, formData: formData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundWhite, AppTheme.primaryTeal],
            stops: [0.0, 0.1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildPersonalInfoPage(),
                      _buildHealthMetricsPage(),
                      _buildRiskFactorsPage(),
                      _buildReviewPage(),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(),
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
          Expanded(
            child: Text(
              'Heart Disease Risk Assessment',
              textAlign: TextAlign.center,
              style: const TextStyle(
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

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: List.generate(_pages.length, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(
                    right: index < _pages.length - 1 ? 8 : 0,
                  ),
                  decoration: BoxDecoration(
                    color:
                        index <= _currentPage
                            ? AppTheme.primaryTeal
                            : AppTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _pages[_currentPage],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSliderField(
              title: 'Age',
              value: _age.toDouble(),
              min: 18,
              max: 100,
              onChanged: (value) => setState(() => _age = value.round()),
              icon: FontAwesomeIcons.cake,
            ),
            const SizedBox(height: 24),
            const Text(
              'Gender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGenderOption(
                    'Male',
                    FontAwesomeIcons.mars,
                    _gender == 'Male',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderOption(
                    'Female',
                    FontAwesomeIcons.venus,
                    _gender == 'Female',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetricsPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Health Metrics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSliderField(
              title: 'Blood Pressure (mmHg)',
              value: _bloodPressure.toDouble(),
              min: 80,
              max: 200,
              onChanged:
                  (value) => setState(() => _bloodPressure = value.round()),
              icon: FontAwesomeIcons.heartPulse,
            ),
            const SizedBox(height: 24),
            _buildSliderField(
              title: 'Heart Rate (BPM)',
              value: _heartRate.toDouble(),
              min: 40,
              max: 150,
              onChanged: (value) => setState(() => _heartRate = value.round()),
              icon: FontAwesomeIcons.heart,
            ),
            const SizedBox(height: 24),
            _buildSliderField(
              title: 'SpO₂ (%)',
              value: _spo2.toDouble(),
              min: 85,
              max: 100,
              onChanged: (value) => setState(() => _spo2 = value.round()),
              icon: FontAwesomeIcons.droplet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskFactorsPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Risk Factors',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildSliderField(
              title: 'Total Cholesterol (mg/dL)',
              value: _cholesterol.toDouble(),
              min: 100,
              max: 400,
              onChanged:
                  (value) => setState(() => _cholesterol = value.round()),
              icon: FontAwesomeIcons.vial,
            ),
            const SizedBox(height: 24),
            _buildSliderField(
              title: 'HDL (mg/dL)',
              value: _hdl.toDouble(),
              min: 20,
              max: 100,
              onChanged: (value) => setState(() => _hdl = value.round()),
              icon: FontAwesomeIcons.arrowUp,
            ),
            const SizedBox(height: 24),
            _buildSliderField(
              title: 'LDL (mg/dL)',
              value: _ldl.toDouble(),
              min: 50,
              max: 300,
              onChanged: (value) => setState(() => _ldl = value.round()),
              icon: FontAwesomeIcons.arrowDown,
            ),
            const SizedBox(height: 24),
            _buildSliderField(
              title: 'Triglycerides (mg/dL)',
              value: _triglycerides.toDouble(),
              min: 50,
              max: 500,
              onChanged:
                  (value) => setState(() => _triglycerides = value.round()),
              icon: FontAwesomeIcons.waveSquare,
            ),
            const SizedBox(height: 24),
            _buildSliderField(
              title: 'Fasting Glucose (mg/dL)',
              value: _fastingGlucose.toDouble(),
              min: 70,
              max: 200,
              onChanged:
                  (value) => setState(() => _fastingGlucose = value.round()),
              icon: FontAwesomeIcons.syringe,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Review Your Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildReviewCard('Personal Info', [
              'Age: $_age years',
              'Gender: $_gender',
            ]),
            const SizedBox(height: 16),
            _buildReviewCard('Health Metrics', [
              'Blood Pressure: $_bloodPressure mmHg',
              'Heart Rate: $_heartRate BPM',
              'SpO₂: $_spo2%',
            ]),
            const SizedBox(height: 16),
            _buildReviewCard('Risk Factors', [
              'Cholesterol: $_cholesterol mg/dL',
              'HDL: $_hdl mg/dL',
              'LDL: $_ldl mg/dL',
              'Triglycerides: $_triglycerides mg/dL',
              'Fasting Glucose: $_fastingGlucose mg/dL',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderField({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return AppTheme.createGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryTeal, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                value.round().toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryTeal,
              inactiveTrackColor: AppTheme.textSecondary.withOpacity(0.3),
              thumbColor: AppTheme.primaryTeal,
              overlayColor: AppTheme.primaryTeal.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _gender = gender),
      child: AppTheme.createGlassCard(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                gender,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected
                          ? AppTheme.primaryTeal
                          : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(String title, List<String> items) {
    return AppTheme.createGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.check,
                    color: AppTheme.successGreen,
                    size: 12,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: AppTheme.createAnimatedButton(
              text: _currentPage == _pages.length - 1 ? 'Predict Risk' : 'Next',
              onPressed: _isLoading ? null : _nextPage,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
