// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionForm _$PredictionFormFromJson(Map<String, dynamic> json) =>
    PredictionForm(
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      smoking: (json['smoking'] as num).toInt(),
      diabetes: (json['diabetes'] as num).toInt(),
      chestPain: (json['chestPain'] as num).toInt(),
      bloodPressure: (json['bloodPressure'] as num).toInt(),
      cholesterol: (json['cholesterol'] as num).toInt(),
      hdl: (json['hdl'] as num).toInt(),
      ldl: (json['ldl'] as num).toInt(),
      triglycerides: (json['triglycerides'] as num).toInt(),
      fastingGlucose: (json['fastingGlucose'] as num).toInt(),
      heartRate: (json['heartRate'] as num).toInt(),
      spo2: (json['spo2'] as num).toInt(),
    );

Map<String, dynamic> _$PredictionFormToJson(PredictionForm instance) =>
    <String, dynamic>{
      'age': instance.age,
      'gender': instance.gender,
      'smoking': instance.smoking,
      'diabetes': instance.diabetes,
      'chestPain': instance.chestPain,
      'bloodPressure': instance.bloodPressure,
      'cholesterol': instance.cholesterol,
      'hdl': instance.hdl,
      'ldl': instance.ldl,
      'triglycerides': instance.triglycerides,
      'fastingGlucose': instance.fastingGlucose,
      'heartRate': instance.heartRate,
      'spo2': instance.spo2,
    };

PredictionResult _$PredictionResultFromJson(Map<String, dynamic> json) =>
    PredictionResult(
      riskLevel: json['riskLevel'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      message: json['message'] as String,
      recommendations:
          (json['recommendations'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$PredictionResultToJson(PredictionResult instance) =>
    <String, dynamic>{
      'riskLevel': instance.riskLevel,
      'confidence': instance.confidence,
      'message': instance.message,
      'recommendations': instance.recommendations,
    };
