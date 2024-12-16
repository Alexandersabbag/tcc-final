// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:tcc_project_iot/controller/device_controller.dart';
import 'package:tcc_project_iot/widgets/utils.dart';

class ConsumptionLogView extends StatefulWidget {
  @override
  _ConsumptionLogViewState createState() => _ConsumptionLogViewState();
}

class _ConsumptionLogViewState extends State<ConsumptionLogView> {
  final deviceController = DeviceController(backendUrl: "http://10.0.2.2:8000");
  List<Map<String, dynamic>> consumptionLogs = [];
  double? totalConsumption;

  @override
  void initState() {
    super.initState();
    calculateConsumption();
    fetchConsumptionLogs();
    fetchTotalConsumption();
  }

  // Função para calcular o consumo
  Future<void> calculateConsumption() async {
    try {
      await deviceController.calculateConsumption();
      print('Consumo calculado com sucesso!');
    } catch (e) {
      print('Erro em calculateConsumption: $e');
    }
  }

  // Função para buscar os dados de consumo
  Future<void> fetchConsumptionLogs() async {
    try {
      final logs = await deviceController.fetchConsumptionLog();
      setState(() {
        consumptionLogs = logs;
      });
    } catch (e) {
      print('Erro ao carregar os logs de consumo: $e');
    }
  }

  //Obter o consumo total do coleção 'consumption_logs'
  Future<void> fetchTotalConsumption() async {
    double? result = await deviceController.totalConsumption();
    setState(() {
      totalConsumption = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          'Logs de Consumo',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: consumptionLogs.isEmpty
                ? NotFound(
                    message: 'Nenhum gasto de energia ou servidor offline.')
                : ListView.builder(
                    itemCount: consumptionLogs.length,
                    itemBuilder: (context, index) {
                      final log = consumptionLogs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        color: Colors.grey[200], 
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Local: ${log["local"]}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              Text(
                                'Cômodo: ${log["room"]}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              Text(
                                'Sessão: ${log["duration"]}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              Text(
                                'Consumo: ${log["consumption_kwh"]} kWh',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Card(
            color: Colors.green[50], 
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Consumo total: $totalConsumption kWh',
                style: const TextStyle(
                  color: Colors.green, 
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
