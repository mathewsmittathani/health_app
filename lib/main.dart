import 'package:flutter/material.dart';
import 'package:health_app/pages/health_screen.dart';
import 'package:health_app/provider/health_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => HealthProvider()),
        ],
        child: HealthApp(),
      ),
    );

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Poppins'),
      debugShowCheckedModeBanner: false,
      home: HealthDataScreen(),
    );
  }
}
