// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:tcc_project_iot/controller/device_controller.dart';
import 'package:tcc_project_iot/widgets/utils.dart';

class DeviceSwitch extends StatefulWidget {
  final int idDevice;
  final String nome;
  final String local;
  final String room;
  final bool initialState;
  final VoidCallback onDelete;

  const DeviceSwitch({
    super.key,
    required this.idDevice,
    required this.nome,
    required this.local,
    required this.room,
    this.initialState = false,
    required this.onDelete,
  });

  @override
  _DeviceSwitch createState() => _DeviceSwitch();
}

class _DeviceSwitch extends State<DeviceSwitch> {
  late bool isSwitched;
  late final DeviceController deviceController;

  @override
  void initState() {
    super.initState();
    isSwitched = widget.initialState;
    deviceController = DeviceController(backendUrl: "http://10.0.2.2:8000");
  }

  //Funçao para o controle do switch. Caso o estado de dispositivo seja alterado, atualiza o endpoint
  void _toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
    });

    final state = isSwitched ? "ON" : "OFF"; // Determine o novo estado

    final data = {
      "id_device": widget.idDevice,
      "local": widget.local,
      "room": widget.room,
      "device": widget.nome,
      "state": state,
      "verify": 0,
      "timestamp": DateTime.now().toIso8601String(),
    };
    deviceController.updateDeviceState(data);
  }

  // Função para abrir o AlertDialog de confirmação de deleção
  void _confirmDeleteDevice() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação de Deleção'),
          content: const Text(
              'Você tem certeza que deseja deletar este dispositivo?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Deletar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteDevice();
              },
            ),
          ],
        );
      },
    );
  }

// Função para deletar o dispositivo usando DeviceSwitch
  Future<void> _deleteDevice() async {
    final deviceData = {
      "id_device": widget.idDevice,
    };

    // Passa o id_device para o endpoint que deve deletar o dispositivo
    final success = await deviceController.deleteDevice(deviceData);

    if (success) {
      widget.onDelete(); // Callback para atualizar a lista após exclusão
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispositivo deletado com sucesso.')),
      );
    } else {
      AlertMessage(title: 'Erro', message: 'Erro ao deletar dispositivo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const int maxLength = 25;

    // Função para decidir qual widget exibir para o texto
    Widget buildDeviceName(String name, String room) {
      final String fullName = "$name do(a) $room";
      if (fullName.length > maxLength) {
        return SizedBox(
          width: double.infinity,
          height: 30,
          child: Marquee(
            text: fullName,
            style: TextStyle(
              color: Colors.green.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            scrollAxis: Axis.horizontal,
            blankSpace: 20.0,
            velocity: 30.0,
            pauseAfterRound: Duration(seconds: 2),
            startPadding: 10.0,
            accelerationDuration: Duration(seconds: 1),
            accelerationCurve: Curves.easeIn,
            decelerationDuration: Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        );
      } else {
        return Text(
          fullName,
          style: TextStyle(
            color: Colors.green.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          overflow: TextOverflow.ellipsis,
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.25),
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: buildDeviceName(widget.nome, widget.room),
                ),
                SizedBox(width: 10),
                Row(
                  children: [
                    Text(
                      'OFF',
                      style: TextStyle(
                        color: !isSwitched ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: isSwitched,
                      onChanged: _toggleSwitch,
                      activeColor: Colors.green,
                      activeTrackColor: Colors.lightGreenAccent,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                    Text(
                      'ON',
                      style: TextStyle(
                        color: isSwitched ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.local,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.lightGreen,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _confirmDeleteDevice,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
