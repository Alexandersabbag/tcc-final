// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceController {
  final String backendUrl;

  DeviceController({required this.backendUrl});

  Future<bool> updateDeviceState(Map<String, dynamic> data) async {
    final url = Uri.parse('$backendUrl/device/update');
    try {
      print("Enviando requisição para: $url");
      print("Dados enviados: $data");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("Código de status da resposta: ${response.statusCode}");
      print("Corpo da resposta: ${response.body}");

      if (response.statusCode == 200) {
        print("Estado do dispositivo atualizado com sucesso.");
        return true;
      } else {
        print(
            "Erro ao atualizar estado: ${response.statusCode}, Detalhes: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erro ao conectar ao backend: $e");
      return false;
    }
  }

  //Adicionar o dispositivo no banco de dados
  Future<void> addDevice(Map<String, dynamic> deviceData) async {
    final url = Uri.parse('$backendUrl/device/add_device');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(deviceData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add device');
    }
  }

  // Deletar dispositivo do backend usando id_device
  Future<bool> deleteDevice(Map<String, dynamic> deviceData) async {
    final url = Uri.parse('$backendUrl/device/delete');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(deviceData),
    );

    return response.statusCode == 200;
  }

  // Obter todos os dispositivos da coleção "devices"
  Future<List<Map<String, dynamic>>> fetchDevices() async {
    final url = Uri.parse('$backendUrl/device/list_devices');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  // Função para obter os consumos de cada dispositivo no endpoint
  Future<List<Map<String, dynamic>>> fetchConsumptionLog() async {
    final url = Uri.parse('$backendUrl/device/list_consumption_logs');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load consumption log');
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  // Buscar todos os tópicos
  Future<List<dynamic>> fetchTopics() async {
    try {
      final response =
          await http.get(Uri.parse('$backendUrl/device/list_topics'));

      if (response.statusCode == 200) {
        final List<dynamic> topics = json.decode(response.body);
        return topics;
      } else {
        throw Exception('Falha ao buscar tópicos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar tópicos: $e');
    }
  }

  //Calcular o consumo
  Future<void> calculateConsumption() async {
    final response = await http.post(
      Uri.parse('$backendUrl/device/calculate_consumption'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao calcular consumo: ${response.body}');
    }
  }

  //Calcular o consumo total
  Future<double?> totalConsumption() async {
    try {
      final response =
          await http.get(Uri.parse('$backendUrl/devices/total_consumption'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['total_consumption'];
      } else {
        print(
            "Failed to fetch total consumption. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching total consumption: $e");
      return null;
    }
  }

  Future<int> getLastDeviceId() async {
    final response = await http.get(Uri.parse('$backendUrl/device/last_id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['last_id'];
    } else {
      throw Exception('Failed to get last device ID');
    }
  }
}
