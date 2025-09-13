// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthData _$HealthDataFromJson(Map<String, dynamic> json) => HealthData(
  timestamp: (json['timestamp'] as num).toInt(),
  heartRate: (json['heartRate'] as num).toInt(),
  spo2: (json['spo2'] as num).toInt(),
  validHR: (json['validHR'] as num).toInt(),
  validSpO2: (json['validSpO2'] as num).toInt(),
);

Map<String, dynamic> _$HealthDataToJson(HealthData instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'heartRate': instance.heartRate,
      'spo2': instance.spo2,
      'validHR': instance.validHR,
      'validSpO2': instance.validSpO2,
    };

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => DeviceInfo(
  device: json['device'] as String,
  uptime: (json['uptime'] as num).toInt(),
  heartRate: (json['heartRate'] as num).toInt(),
  spo2: (json['spo2'] as num).toInt(),
);

Map<String, dynamic> _$DeviceInfoToJson(DeviceInfo instance) =>
    <String, dynamic>{
      'device': instance.device,
      'uptime': instance.uptime,
      'heartRate': instance.heartRate,
      'spo2': instance.spo2,
    };

SystemInfo _$SystemInfoFromJson(Map<String, dynamic> json) => SystemInfo(
  chipModel: json['chipModel'] as String,
  cpuFreq: (json['cpuFreq'] as num).toInt(),
  freeHeap: (json['freeHeap'] as num).toInt(),
);

Map<String, dynamic> _$SystemInfoToJson(SystemInfo instance) =>
    <String, dynamic>{
      'chipModel': instance.chipModel,
      'cpuFreq': instance.cpuFreq,
      'freeHeap': instance.freeHeap,
    };
