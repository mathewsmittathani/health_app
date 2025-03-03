import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app/models/aggregated_health_data_model.dart';
import 'package:health_app/models/step_model.dart';
import 'package:health_app/services/health_service.dart';
import 'package:health_app/utils.dart';
import 'package:intl/intl.dart';

class HealthProvider with ChangeNotifier {
  final HealthService _healthService = HealthService();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _isSyncing = false;
  int _selectedFilterIndex = 0;
  bool _isAuthorized = false;
  List<AggregatedHealthData> _healthData = [];
  List<StepModel> _stepModel = [];

  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  int get selectedFilterIndex => _selectedFilterIndex;
  List<AggregatedHealthData> get healthData => _healthData;
  List<StepModel> get stepModel => _stepModel;

  Future<void> fetchHealthData(
      {DateTime? startTime,
      DateTime? endTime,
      List<HealthDataType>? types}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!_isAuthorized) {
        _isAuthorized = await _healthService.requestAuthorization();
      }
      if (_isAuthorized) {
        List<HealthDataPoint> rawData =
            await _healthService.fetchHealthData(startTime, endTime, types);
        List<HealthDataPoint> filteredData =
            _healthService.health.removeDuplicates(rawData);
        _healthData = aggregateHealthData(filteredData);
        _errorMessage = '';
      } else {
        _errorMessage = "Authorization not granted";
      }
    } catch (e) {
      _errorMessage = "Failed to fetch health data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStepData() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isAuthorized) {
        Map<String, int> hiveData = await _healthService.getAllStepsFromHive();

        if (hiveData.isNotEmpty) {
          _stepModel = hiveData.entries
              .map((entry) =>
                  StepModel(date: parseDate(entry.key), steps: entry.value))
              .toList();
          _isLoading = false;
          notifyListeners();
          return;
        }
        _errorMessage = '';
      }
    } catch (e) {
      _errorMessage = "Failed to fetch health data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  onSync() async {
    _isSyncing = true;
    notifyListeners();
    try {
      if (!_isAuthorized) {
        _isAuthorized = await _healthService.requestAuthorization();
      }
      if (_isAuthorized) {
        //from Health API
        List<HealthDataPoint> rawData = await _healthService.fetchHealthData(
          DateTime.now().subtract(Duration(days: 90)),
          DateTime.now(),
          [HealthDataType.STEPS],
        );
        List<HealthDataPoint> filteredData =
            _healthService.health.removeDuplicates(rawData);
        // log(filteredData.toString());
        Map<String, int> stepsByDate = {};
        if (filteredData.isEmpty) return;

        DateTime startDate = filteredData.first.dateFrom;
        DateTime endDate = filteredData.first.dateFrom;

        for (var data in filteredData) {
          if (data.type == HealthDataType.STEPS) {
            if (data.dateFrom.isBefore(startDate)) startDate = data.dateFrom;
            if (data.dateFrom.isAfter(endDate)) endDate = data.dateFrom;

            String dateKey = DateFormat('yyyy-MM-dd').format(data.dateFrom);
            stepsByDate[dateKey] = (stepsByDate[dateKey] ?? 0) +
                (data.value is NumericHealthValue
                    ? (data.value as NumericHealthValue).numericValue.toInt()
                    : 0);
          }
        }
        await _healthService.saveStepDataToHive(stepsByDate);
      } else {
        log('Not Authorized');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  selectFilter(int index) async {
    final now = DateTime.now();
    DateTime startTime;
    DateTime endTime;

    _selectedFilterIndex = index;

    if (index == 0) {
      // Today
      startTime = DateTime(now.year, now.month, now.day);
      endTime = now;
    } else {
      DateTime selectedDate = now.subtract(Duration(days: index));
      startTime =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      endTime = startTime.add(Duration(days: 1)).subtract(
            Duration(milliseconds: 1),
          );
    }

    await fetchHealthData(startTime: startTime, endTime: endTime);
  }
}
