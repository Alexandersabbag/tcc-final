// ignore_for_file: library_private_types_in_public_api, unused_element, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:tcc_project_iot/widgets/add_device.dart';
import 'package:tcc_project_iot/widgets/device_switch.dart';
import 'package:tcc_project_iot/controller/device_controller.dart';
import 'package:tcc_project_iot/widgets/utils.dart';

class PrincipalView extends StatefulWidget {
  const PrincipalView({super.key});

  @override
  _PrincipalViewState createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  List<Map<String, dynamic>> devices = [];
  late DeviceController deviceController;

  @override
  void initState() {
    super.initState();
    deviceController = DeviceController(backendUrl: "http://10.0.2.2:8000");
    _fetchDevices();
  }

// Função para buscar dispositivos no backend
  Future<void> _fetchDevices() async {
    try {
      final fetchedDevices = await deviceController.fetchDevices();
      setState(() {
        devices = fetchedDevices.isEmpty
            ? [] // Caso não haja dispositivos, lista vazia
            : fetchedDevices.map((device) {
                return {
                  "id_device": device["id_device"] ?? 0,
                  "local": device['local'] ?? 'Desconhecido',
                  "room": device['room'] ?? 'Desconhecido',
                  "device": device['device'] ?? 'Dispositivo',
                  "state": device['state'] ?? 'OFF',
                };
              }).toList();
      });
    } catch (e) {
      AlertMessage(title: 'Erro', message: 'Erro ao carregar dispositivos: $e');
    }
  }

// Função de callback para remover dispositivo da lista localmente após deleção
  void _removeDeviceFromList(int idDevice) {
    setState(() {
      devices.removeWhere((device) => device['id_device'] == idDevice);
    });
  }

  void _openAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddDevice(
          refreshDeviceList: (newDevice) {
            setState(() {
              devices.add(newDevice);
            });
          },
        );
      },
    );
  }

  // Exibir o diálogo de adição de dispositivo
  void _showAddDeviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddDevice(
          refreshDeviceList: (newDevice) {
            // Atualiza a lista de dispositivos, se necessário
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          'Lista de Dispositivos',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 90,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.green,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context); // Fecha o Drawer
                        },
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23, // Reduzido em 1
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomListTile(
              title: 'Histórico de consumo',
              icon: Icons.flash_on,
              backgroundColor: Colors.green.withOpacity(1),
              onTap: () {
                Navigator.pushNamed(context, 'consumption_log');
              },
            ),
            SizedBox(
              height: 5,
            ),
            CustomListTile(
              title: 'Topicos Enviados',
              icon: Icons.send,
              backgroundColor: Colors.green.withOpacity(1),
              onTap: () {
                Navigator.pushNamed(context, 'topics_send');
              },
            ),
            SizedBox(
              height: 5,
            ),
            CustomListTile(
              title: 'Consumo Individual',
              icon: Icons.online_prediction,
              backgroundColor: Colors.green.withOpacity(1),
              onTap: () {
                Navigator.pushNamed(context, 'individual_consumption');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          devices.isEmpty
              ? NotFound(
                  message:
                      "Você ainda não adicionou nenhum dispositivo.\nAperte em '+' para adicionar um novo.")
              : Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return DeviceSwitch(
                        idDevice: device['id_device'],
                        nome: device['device'],
                        local: device['local'],
                        room: device['room'],
                        initialState: device['state'] == "ON",
                        onDelete: () =>
                            _removeDeviceFromList(device['id_device']),
                      );
                    },
                  ),
                ),
          Positioned(
            bottom: 3,
            left: 16,
            right: 16,
            child: Center(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: FloatingActionButton(
                    onPressed: _openAddDeviceDialog,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
