import 'package:json_annotation/json_annotation.dart';

part 'health_data.g.dart';

@JsonSerializable()
class HealthData {
  final int timestamp;
  final int heartRate;
  final int spo2;
  final int validHR;
  final int validSpO2;

  const HealthData({
    required this.timestamp,
    required this.heartRate,
    required this.spo2,
    required this.validHR,
    required this.validSpO2,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) => _$HealthDataFromJson(json);
  Map<String, dynamic> toJson() => _$HealthDataToJson(this);

  HealthData copyWith({
    int? timestamp,
    int? heartRate,
    int? spo2,
    int? validHR,
    int? validSpO2,
  }) {
    return HealthData(
      timestamp: timestamp ?? this.timestamp,
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      validHR: validHR ?? this.validHR,
      validSpO2: validSpO2 ?? this.validSpO2,
    );
  }

  bool get isValidHeartRate => validHR == 1 && heartRate > 0;
  bool get isValidSpO2 => validSpO2 == 1 && spo2 > 70 && spo2 <= 100;
}

@JsonSerializable()
class DeviceInfo {
  final String device;
  final int uptime;
  final int heartRate;
  final int spo2;

  const DeviceInfo({
    required this.device,
    required this.uptime,
    required this.heartRate,
    required this.spo2,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => _$DeviceInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceInfoToJson(this);
}

@JsonSerializable()
class SystemInfo {
  final String chipModel;
  final int cpuFreq;
  final int freeHeap;

  const SystemInfo({
    required this.chipModel,
    required this.cpuFreq,
    required this.freeHeap,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) => _$SystemInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SystemInfoToJson(this);
}