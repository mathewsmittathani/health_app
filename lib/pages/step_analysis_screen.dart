import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:health/health.dart';

import 'package:health_app/models/step_model.dart';
import 'package:health_app/provider/health_provider.dart';
import 'package:health_app/utils.dart';
import 'package:health_app/widgets/arc_progress_bar.dart';
import 'package:health_app/widgets/line_chart_widget.dart';
import 'package:health_app/widgets/step_input_textfield_widget.dart';

class StepAnalysisScreen extends StatefulWidget {
  const StepAnalysisScreen({super.key});

  @override
  State<StepAnalysisScreen> createState() => _StepAnalysisScreenState();
}

class _StepAnalysisScreenState extends State<StepAnalysisScreen> {
  TextEditingController controller = TextEditingController();

  _fetchData() async => await context.read<HealthProvider>().fetchStepData();

  @override
  void initState() {
    Future.delayed(Duration.zero, () => _fetchData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 228, 227, 227),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                    blurRadius: 2,
                    color: Colors.black.withValues(alpha: 0.15),
                  )
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step Analysis',
                    style: TextStyle(color: Colors.green, fontSize: 20),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You can update your steps anytime',
                    style: TextStyle(color: Colors.green),
                  ),
                  SizedBox(height: 8),
                  Selector<HealthProvider, bool>(
                    selector: (_, provider) => provider.isSyncing,
                    builder: (_, isSyncing, __) => ElevatedButton(
                      onPressed: isSyncing
                          ? null
                          : () async {
                              final health = context.read<HealthProvider>();
                              await health.onSync();
                              await health.fetchStepData();
                            },
                      child: Text(isSyncing ? 'Syncing' : 'Sync now'),
                    ),
                  ),
                  SizedBox(height: 32),
                  StepInputTextfieldWidget(controller: controller),
                  SizedBox(height: 32),
                  Selector<HealthProvider, List<StepModel>>(
                    selector: (_, provider) => provider.stepModel,
                    builder: (_, stepModel, __) {
                      return LineChartWidget(
                        stepModels: stepModel,
                        flspots: List.generate(
                          stepModel.length,
                          (i) => FlSpot(
                            i.toDouble(),
                            stepModel[i].steps.toDouble(),
                          ),
                        ),
                      );
                    },
                  ),
                  Selector<HealthProvider, int>(
                      selector: (_, provider) => provider.stepModel.isNotEmpty
                          ? provider.stepModel
                              .firstWhere((e) => isSameDateAsToday(e.date))
                              .steps
                          : 0,
                      builder: (_, steps, __) => steps > 0
                          ? ArcProgressBarWidget(steps: steps, goal: 50000)
                          : const SizedBox.shrink()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
