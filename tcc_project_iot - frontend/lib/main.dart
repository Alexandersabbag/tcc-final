import 'package:flutter/material.dart';
import 'package:tcc_project_iot/view/devices_consumption.dart';
import 'package:tcc_project_iot/view/topics_send.dart';
import 'view/principal_view.dart';
import 'view/consumption_log_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'principal_view',
      routes: {
        'principal_view': (context) => const PrincipalView(),
        'consumption_log': (context) => ConsumptionLogView(),
        'topics_send': (context) => TopicsSend(),
        'individual_consumption': (context) => DeviceConsumption(),
      },
    );
  }
}
