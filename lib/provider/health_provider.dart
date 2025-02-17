import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_app/models/aggregated_health_data_model.dart';
import 'package:health_app/services/health_service.dart';
import 'package:health_app/utils.dart';

class HealthProvider with ChangeNotifier {
  final HealthService _healthService = HealthService();

  String _errorMessage = '';
  bool _isLoading = false;
  int _selectedFilterIndex = 0;
  bool _isAuthorized = false;
  List<AggregatedHealthData> _healthData = [];

  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  int get selectedFilterIndex => _selectedFilterIndex;
  List<AggregatedHealthData> get healthData => _healthData;

  Future<void> fetchHealthData({DateTime? startTime, DateTime? endTime}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!_isAuthorized) {
        _isAuthorized = await _healthService.requestAuthorization();
      }

      if (_isAuthorized) {
        List<HealthDataPoint> rawData =
            await _healthService.fetchHealthData(startTime, endTime);
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
      endTime = startTime.add(Duration(days: 1)).subtract(Duration(
          milliseconds:
              1)); //adjusts the end time to 23:59:59.999 of the selected day
    }

    await fetchHealthData(startTime: startTime, endTime: endTime);
  }
}
