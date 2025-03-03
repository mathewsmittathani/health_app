import 'dart:developer';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:hive_ce/hive.dart';
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

  Future<List<HealthDataPoint>> fetchHealthData(DateTime? startTime,
      DateTime? endTime, List<HealthDataType>? healthTypes) async {
    final now = DateTime.now();
    final start = startTime ?? DateTime(now.year, now.month, now.day);
    final end = endTime ?? now;
    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
      types: healthTypes ?? types,
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

  Future<void> saveStepDataToHive(Map<String, int> stepsByDate) async {
    var box = Hive.box('stepData');

    for (var entry in stepsByDate.entries) {
      if (box.get(entry.key) != entry.value) {
        await box.put(entry.key, entry.value);
      }
    }
    log("Step data saved to Hive: $stepsByDate");
  }

  Future<Map<String, int>> getAllStepsFromHive() async {
    var box = Hive.box('stepData');
    Map<String, int> stepData = {};

    // Retrieve data from Hive
    for (var key in box.keys) {
      stepData[key.toString()] = await box.get(key, defaultValue: 0);
    }

    if (stepData.isEmpty) return {};

    List<String> sortedKeys = stepData.keys.toList()..sort();

    // Earliest recorded date
    DateTime startDate = DateTime.parse(sortedKeys.first);
    DateTime today = DateTime.now();
    // Fill in missing dates with 0 steps
    DateTime currentDate = startDate;
    while (!currentDate.isAfter(today)) {
      String dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
      stepData.putIfAbsent(dateKey, () => 0);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Sort by date keys
    Map<String, int> sortedStepData = Map.fromEntries(
      stepData.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    log('Hive data with filled missing dates: $sortedStepData');
    return sortedStepData;
  }
}
