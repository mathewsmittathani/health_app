import 'dart:io';

import 'package:health/health.dart';

class HealthService {
  final health = Health();

  final types = [
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.STEPS,
    if (Platform.isAndroid) HealthDataType.SLEEP_SESSION,
    if (Platform.isIOS) ...[
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_IN_BED,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM
    ]
  ];

  Future<List<HealthDataPoint>> fetchHealthData(
      DateTime? startTime, DateTime? endTime) async {
    final now = DateTime.now();
    final start = startTime ?? DateTime(now.year, now.month, now.day);
    final end = endTime ?? now;

    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
      types: types,
      startTime: start,
      endTime: end,
    );

    return healthData;
  }

  Future<bool> requestAuthorization() async {
    try {
      await health.configure();
      return await health.requestAuthorization(types);
    } catch (e) {
      // print("Authorization Error: $e");
      return false;
    }
  }

  Future<HealthConnectSdkStatus?> checkHealthConnectStatus() async {
    if (Platform.isAndroid) {
      final status = await health.getHealthConnectSdkStatus();
      // print("Health Connect Status: ${status?.name}");
      return status;
    } else {
      return null;
    }
  }
}
