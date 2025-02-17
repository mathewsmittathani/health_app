import 'package:health/health.dart';
import 'models/aggregated_health_data_model.dart';

List<AggregatedHealthData> aggregateHealthData(
    List<HealthDataPoint> healthData) {
  Map<String, double> summedValues = {};
  Map<String, String> unitMap = {};

  for (var dataPoint in healthData) {
    String type =
        dataPoint.type.toString().split('.').last.replaceAll('_', ' ');
    double value = double.tryParse(
          dataPoint.value.toString().split(':').last,
        ) ??
        0.0;
    String unit = dataPoint.unit.name.replaceAll('_', ' ');

    if (summedValues.containsKey(type)) {
      summedValues[type] = summedValues[type]! + value;
    } else {
      summedValues[type] = value;
      unitMap[type] = unit;
    }
  }

  return summedValues.entries.map((entry) {
    String type = entry.key;
    double value = entry.value;
    String unit = unitMap[type]!;
    return AggregatedHealthData(
      type: type,
      value: value,
      unit: unit,
    );
  }).toList();
}
