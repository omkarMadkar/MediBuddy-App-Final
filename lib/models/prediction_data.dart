import 'package:json_annotation/json_annotation.dart';

part 'prediction_data.g.dart';

@JsonSerializable()
class PredictionForm {
  final int age;
  final String gender;
  final int smoking;
  final int diabetes;
  final int chestPain;
  final int bloodPressure;
  final int cholesterol;
  final int hdl;
  final int ldl;
  final int triglycerides;
  final int fastingGlucose;
  final int heartRate;
  final int spo2;

  const PredictionForm({
    required this.age,
    required this.gender,
    required this.smoking,
    required this.diabetes,
    required this.chestPain,
    required this.bloodPressure,
    required this.cholesterol,
    required this.hdl,
    required this.ldl,
    required this.triglycerides,
    required this.fastingGlucose,
    required this.heartRate,
    required this.spo2,
  });

  factory PredictionForm.fromJson(Map<String, dynamic> json) => _$PredictionFormFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionFormToJson(this);

  Map<String, dynamic> toMLInput() {
    return {
      'age': age,
      'gender': gender == 'Male' ? 1 : 0,
      'smoking': smoking,
      'diabetes': diabetes,
      'chest_pain': chestPain,
      'blood_pressure': bloodPressure,
      'cholesterol': cholesterol,
      'hdl': hdl,
      'ldl': ldl,
      'triglycerides': triglycerides,
      'fasting_glucose': fastingGlucose,
      'heart_rate': heartRate,
      'spo2': spo2,
    };
  }
}

@JsonSerializable()
class PredictionResult {
  final String riskLevel;
  final double confidence;
  final String message;
  final List<String> recommendations;

  const PredictionResult({
    required this.riskLevel,
    required this.confidence,
    required this.message,
    required this.recommendations,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) => _$PredictionResultFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionResultToJson(this);

  static PredictionResult calculateRisk(Map<String, dynamic> mlInput) {
    // Simple risk calculation based on common factors
    int riskScore = 0;
    
    // Age factor
    if (mlInput['age'] > 65) riskScore += 3;
    else if (mlInput['age'] > 55) riskScore += 2;
    else if (mlInput['age'] > 45) riskScore += 1;
    
    // Gender factor (males have higher risk)
    if (mlInput['gender'] == 1) riskScore += 1;
    
    // Smoking
    if (mlInput['smoking'] == 1) riskScore += 3;
    
    // Diabetes
    if (mlInput['diabetes'] == 1) riskScore += 2;
    
    // Blood pressure
    if (mlInput['blood_pressure'] > 140) riskScore += 2;
    else if (mlInput['blood_pressure'] > 120) riskScore += 1;
    
    // Cholesterol
    if (mlInput['cholesterol'] > 240) riskScore += 2;
    else if (mlInput['cholesterol'] > 200) riskScore += 1;
    
    // HDL (lower is worse)
    if (mlInput['hdl'] < 40) riskScore += 2;
    else if (mlInput['hdl'] < 50) riskScore += 1;
    
    // Heart rate
    if (mlInput['heart_rate'] > 100) riskScore += 1;
    else if (mlInput['heart_rate'] < 60) riskScore += 1;
    
    // SpO2
    if (mlInput['spo2'] < 95) riskScore += 2;
    else if (mlInput['spo2'] < 98) riskScore += 1;

    String riskLevel;
    double confidence;
    String message;
    List<String> recommendations;

    if (riskScore >= 8) {
      riskLevel = 'High';
      confidence = 0.85 + (riskScore - 8) * 0.02;
      message = 'High risk detected. Please consult a healthcare professional immediately.';
      recommendations = [
        'Schedule an appointment with a cardiologist',
        'Monitor your vitals regularly',
        'Follow a heart-healthy diet',
        'Engage in regular exercise',
        'Quit smoking if applicable',
        'Manage stress levels'
      ];
    } else if (riskScore >= 5) {
      riskLevel = 'Moderate';
      confidence = 0.70 + (riskScore - 5) * 0.05;
      message = 'Moderate risk detected. Consider lifestyle changes and regular monitoring.';
      recommendations = [
        'Regular health checkups',
        'Maintain a balanced diet',
        'Exercise regularly',
        'Monitor blood pressure',
        'Reduce stress',
        'Get adequate sleep'
      ];
    } else {
      riskLevel = 'Low';
      confidence = 0.60 + riskScore * 0.05;
      message = 'Low risk detected. Continue maintaining a healthy lifestyle.';
      recommendations = [
        'Maintain current healthy habits',
        'Regular exercise',
        'Balanced diet',
        'Annual health checkups',
        'Stay hydrated',
        'Manage stress'
      ];
    }

    return PredictionResult(
      riskLevel: riskLevel,
      confidence: confidence.clamp(0.0, 1.0),
      message: message,
      recommendations: recommendations,
    );
  }
}