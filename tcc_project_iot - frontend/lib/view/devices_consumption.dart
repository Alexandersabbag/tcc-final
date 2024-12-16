// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:tcc_project_iot/controller/device_controller.dart';
import 'package:tcc_project_iot/widgets/utils.dart';

class DeviceConsumption extends StatefulWidget {
  const DeviceConsumption({super.key});

  @override
  State<DeviceConsumption> createState() => _DeviceConsumptionState();
}

class _DeviceConsumptionState extends State<DeviceConsumption> {
  List<Map<String, dynamic>> individualConsumptions = [];
  final deviceController = DeviceController(backendUrl: "http://10.0.2.2:8000");
  List<Map<String, dynamic>> consumptionLogs = [];

  @override
  void initState() {
    super.initState();
    fetchConsumptionLogs().then((_) {
      individualDeviceConsumption();
    });
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

  void individualDeviceConsumption() {
    try {
      Map<String, Map<String, dynamic>> consumptionMap = {};

      for (var log in consumptionLogs) {
        final idDevice = log['id_device'].toString();
        final consumption = log['consumption_kwh'] ?? 0.0;

        if (!consumptionMap.containsKey(idDevice)) {
          consumptionMap[idDevice] = {
            "device": log['device'], // Nome do dispositivo
            "local": log['local'], // Local do dispositivo
            "room": log['room'], // Sala do dispositivo
            "total_consumption": 0.0, // Inicialize o consumo total
          };
        }
        consumptionMap[idDevice]!['total_consumption'] += consumption;
      }
      setState(() {
        individualConsumptions = consumptionMap.values.toList();
      });
    } catch (e) {
      print('Erro ao calcular consumo individual: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          'Consumo individual',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: individualConsumptions.isEmpty
          ? NotFound(message: 'Nenhum consumo registrado ou servidor offline')
          : ListView.builder(
              itemCount: individualConsumptions.length,
              itemBuilder: (context, index) {
                final device = individualConsumptions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dispositivo: ${device["device"]}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Local: ${device["local"]}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Sala: ${device["room"]}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Consumo Total: ${device["total_consumption"].toStringAsFixed(2)} kWh',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
