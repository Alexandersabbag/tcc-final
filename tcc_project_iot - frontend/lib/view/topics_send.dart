import 'package:flutter/material.dart';
import 'package:tcc_project_iot/controller/device_controller.dart'; // Atualize com o caminho correto
import 'package:tcc_project_iot/widgets/utils.dart'; // Atualize com o caminho correto

class TopicsSend extends StatefulWidget {
  const TopicsSend({super.key});

  @override
  State<TopicsSend> createState() => _TopicsSendState();
}

class _TopicsSendState extends State<TopicsSend> {
  List<Map<String, dynamic>> topics = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchTopicsWithTimeout();
  }

  Future<void> _fetchTopicsWithTimeout() async {
    try {
      var controller = DeviceController(backendUrl: "http://10.0.2.2:8000");
      var fetchedTopics = await controller.fetchTopics().timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          setState(() {
            isLoading = false;
            hasError = true;
          });
          return [];
        },
      );
      setState(() {
        topics = fetchedTopics.reversed
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    String local = topic['local'];
    String room = topic['room'];
    String device = topic['device'];
    String dateTime = topic['date_time'];
    String topicString = topic['topic'];

    // Separar data e horário
    List<String> dateTimeParts = dateTime.split(' - ');
    String date = dateTimeParts[0];
    String time = dateTimeParts[1];

    // Separar o comando final (estado)
    List<String> topicParts = topicString.split('/');
    String command = topicParts.sublist(0, topicParts.length - 1).join('/');
    String state = topicParts.last.toLowerCase();

    Color stateColor = state == 'on' ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local: $local',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Cômodo: $room',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Dispositivo: $device',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Data: $date',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Horário: $time',
              style: const TextStyle(fontSize: 20),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Comando: $command/',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontStyle: FontStyle.italic),
                  ),
                  TextSpan(
                    text: state,
                    style: TextStyle(
                        color: stateColor,
                        fontSize: 20,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green,
        centerTitle: true,
        title: const Text(
          'Histórico de Comandos',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? NotFound(message: "Erro de conexão com o servidor.")
              : ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    return _buildTopicCard(topic);
                  },
                ),
    );
  }
}
