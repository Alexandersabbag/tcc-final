// ignore_for_file: sort_child_properties_last, use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tcc_project_iot/controller/device_controller.dart';
import 'package:tcc_project_iot/widgets/utils.dart';

class AddDevice extends StatefulWidget {
  final Function(Map<String, dynamic>) refreshDeviceList;

  const AddDevice({super.key, required this.refreshDeviceList});

  @override
  // ignore: library_private_types_in_public_api
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _deviceController = TextEditingController();
  final TextEditingController _powerController = TextEditingController();
  final DeviceController deviceController =
      DeviceController(backendUrl: "http://10.0.2.2:8000");

  Future<void> _addDevice() async {
    //variavéis que irão compor o os dados da coleção "topics_history"

    String local = _localController.text;
    String room = _roomController.text;
    String device = _deviceController.text;
    String power = _powerController.text;

    int lastId = await deviceController.getLastDeviceId();
    int newDeviceId = lastId + 1;
    double powerDecimal = double.tryParse(power) ?? 0.0;

    if (local.isNotEmpty &&
        room.isNotEmpty &&
        device.isNotEmpty &&
        power.isNotEmpty) {
      final data = {
        "id_device": newDeviceId,
        "local": local,
        "room": room,
        "device": device,
        "power": powerDecimal,
        "state": "OFF",
      };
      try {
        await deviceController.addDevice(data);
        widget.refreshDeviceList(data);
        Navigator.of(context).pop();
        _localController.clear();
        _roomController.clear();
        _deviceController.clear();
        _powerController.clear();
      } catch (e) {
        AlertMessage(title: 'Erro', message: 'Erro ao adicionar dispositivo.');
      }
    } else {
      AlertMessage(
          title: 'Aviso', message: 'Por favor, preencha todos os campos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(0.9),
      title: const Text('Adicionar Dispositivo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _localController,
              decoration: const InputDecoration(hintText: 'Local'),
            ),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(hintText: 'Cômodo'),
            ),
            TextField(
              controller: _deviceController,
              decoration: const InputDecoration(hintText: 'Dispositivo'),
            ),
            TextField(
              controller: _powerController,
              decoration: const InputDecoration(hintText: 'Potência'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Adicionar', style: TextStyle(color: Colors.white)),
          onPressed: _addDevice,
        ),
      ],
    );
  }
}
