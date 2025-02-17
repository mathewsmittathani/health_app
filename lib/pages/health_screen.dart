import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:health_app/provider/health_provider.dart';
import 'package:health_app/widgets/filter_button.dart';
import 'package:health_app/widgets/health_data_card.dart';
import 'package:health_app/widgets/empty_state_text.dart';

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  HealthDataScreenState createState() => HealthDataScreenState();
}

class HealthDataScreenState extends State<HealthDataScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().fetchHealthData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(137, 32, 32, 32),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(137, 32, 32, 32),
        title: Text(
          "Health",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<HealthProvider>().selectFilter(0),
            icon: Icon(Icons.refresh, color: Colors.blueAccent),
          )
        ],
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, _) {
          if (healthProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                healthProvider.errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            );
          } else {
            return Column(
              children: [
                //date filters
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(8, (index) {
                      DateTime date =
                          DateTime.now().subtract(Duration(days: index));
                      return index == 0
                          ? 'Today'
                          : index == 1
                              ? 'Yesterday'
                              : DateFormat('dd MMM').format(date);
                    }).asMap().entries.map((e) {
                      int index = e.key;
                      String buttonName = e.value;
                      return FilterButton(
                        buttonName: buttonName,
                        onTap: () => healthProvider.selectFilter(index),
                        isSelected: healthProvider.selectedFilterIndex == index,
                      );
                    }).toList(),
                  ),
                ),
                healthProvider.isLoading
                    ? Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.tealAccent,
                            strokeWidth: 5,
                          ),
                        ),
                      )
                    : Expanded(
                        child: healthProvider.healthData.isEmpty
                            ? const Center(child: EmptyStateText())
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                itemCount: healthProvider.healthData.length,
                                itemBuilder: (context, index) {
                                  final data = healthProvider.healthData[index];
                                  return HealthDataCard(
                                    type: data.type,
                                    value: data.value,
                                    unit: data.unit,
                                  );
                                },
                              ),
                      ),
              ],
            );
          }
        },
      ),
    );
  }
}
