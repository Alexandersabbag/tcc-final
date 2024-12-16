from flask import Flask, request, jsonify
from datetime import datetime

from application.mqtt.mqtt_client_connect import MqttClientConnection
from application.mqtt.broker_configs import mqtt_broker_configs

from application.databank.database_operations import db_add_topic, db_update_device, db_add_device, \
    db_list_devices, db_delete_device, db_calculate_consumption, db_get_last_device_id, db_list_topics, \
    db_list_consumption_logs, db_total_consumption

# Identificador app para inicializar o flask
app = Flask(__name__)

# Endpoint para atualizar o estado do dispositivo
@app.route('/device/update', methods=['POST'])
def update_device_state():
    data = request.get_json()
    id_device = data.get("id_device")
    local = data.get("local")
    device = data.get("device")
    room = data.get("room")
    state = data.get("state")
    verify = data.get("verify", 0)
    timestamp = data.get("timestamp", datetime.now().isoformat())
    topic = f"{local}/{room}/{device}/{state}"

    topic_data = {
        "id_device": id_device,
        "local": local,
        "device": device,
        "room": room,
        "state": state,
        "verify": verify,
        "timestamp": timestamp,
        "topic": topic
    }

    # Cliente do MQTT
    mqtt_client_connection = MqttClientConnection(
        mqtt_broker_configs["HOST"],
        mqtt_broker_configs["PORT"],
        mqtt_broker_configs["CLIENT_NAME"],
        mqtt_broker_configs["KEEPALIVE"],
    )

    # Armazenar os dados no MongoDB
    db_add_topic(id_device, topic, timestamp, verify)
    result = db_update_device(id_device, local, room, device, state)

    # Iniciar conexão com o broker e inscrever no tópico
    mqtt_client_connection.start_connection(topic)
    mqtt_client_connection.end_connection()

    if result.modified_count > 0:
        return jsonify({"status": "success", **topic_data}), 200
    else:
        return jsonify({"status": "success", "message": "Device state updated, but no changes were made."}), 200


@app.route('/device/add_topic', methods=['POST'])
def add_topic():
    try:
        # Obtém os dados da requisição
        data = request.get_json()

        # Extrai os dados do corpo da requisição
        id_device = data.get("id_device")
        local = data.get("local")
        device = data.get("device")
        room = data.get("room")
        state = data.get("state")
        verify = data.get("verify", 0)
        timestamp = data.get("timestamp", datetime.now().isoformat())

        # Criação do tópico
        topic = f"{local}/{room}/{device}/{state}"

        # Chama a função para adicionar o tópico ao banco de dados
        result = db_add_topic(id_device, topic, timestamp, verify)

        # Retorna a resposta baseada no resultado da inserção
        if result == "success":
            return jsonify({"message": "Topic added succesfully!"}), 200
        else:
            return jsonify({"error": "Failed to add topic"}), 500

    except Exception as e:
        return jsonify({"error": "Processing Error", "details": str(e)}), 500


# Endpoint para adicionar um novo dispositivo no banco de dados
@app.route('/device/add_device', methods=['POST'])
def add_device():
    try:
        data = request.get_json()  # Obter dados JSON da solicitação

        # Extrair dados do dispositivo
        new_device = {
            "id_device": data.get("id_device"),
            "local": data.get("local"),
            "room": data.get("room"),
            "device": data.get("device"),
            "power" : data.get("power"),
            "state": data.get("state", "OFF")  # Estado padrão "OFF" se não especificado
        }

        result = db_add_device(new_device)

        if result:
            return jsonify({"message": "Device added successfully", "id_device": str(result.inserted_id)}), 201
        else:
            return jsonify({"error": "Failed to add device"}), 500

    except Exception as e:
        # Em caso de erro, retornar mensagem de erro
        return jsonify({"error": "Failed to add device", "details": str(e)}), 500


# Endpoint para listar todos os dispositivos com o estado atual
@app.route('/device/list_devices', methods=['GET'])
def list_devices():
    try:
        devices = db_list_devices()
        if devices is None:
            return jsonify({"error": "Failed to retrieve devices"}), 500

        return jsonify(devices), 200  # Retorna a lista de dispositivos

    except Exception as e:
        return jsonify({"error": "Failed to retrieve devices", "details": str(e)}), 500


#Listar o historico de "topics_collection"
@app.route('/device/list_topics', methods=['GET'])
def list_topics():
    try:
        topics = db_list_topics()  # Chama a função para listar os tópicos
        if topics is None:
            return jsonify({"error": "Failed to retrieve topics"}), 500

        return jsonify(topics), 200  # Retorna a lista de tópicos

    except Exception as e:
        return jsonify({"error": "Failed to retrieve topics", "details": str(e)}), 500


# Listar a coleção "Consumption_logs"
@app.route('/device/list_consumption_logs', methods=['GET'])
def get_consumption_logs():
    try:
        logs = db_list_consumption_logs()
        return jsonify(logs), 200 if logs else 404
    except Exception as e:
        return jsonify({"error": "Erro ao buscar os logs de consumo", "detalhes": str(e)}), 500



# Endpoint para o cálculo do consumo de cada dispositivo na coleção "devices"
@app.route('/device/calculate_consumption', methods=['POST'])
def calculate_consumption_log():
    try:
        # Chama a função de cálculo de consumo
        success = db_calculate_consumption()

        if success == "success":
            return jsonify({"message": "Success."}), 200
        else:
            return jsonify({"error": "Math error"}), 500

    except Exception as e:
        return jsonify({"error": "Failed to calculate consumption.", "details": str(e)}), 500

#Endpoint para calculo do consumo total
@app.route('/devices/total_consumption', methods=['GET'])
def total_consumption():
    try:
        # Chama a função para calcular o consumo total
        result = db_total_consumption()

        # Verifica se ocorreu um erro
        if "error" in result:
            return jsonify({"error": result["error"]}), 500

        # Retorna o consumo total
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": "Falha ao obter o consumo total", "detalhes": str(e)}), 500


@app.route('/device/last_id', methods=['GET'])
def last_device_id():
    try:
        last_id = db_get_last_device_id()  # Chama a função que busca o último id_device
        return jsonify({"last_id": int (last_id)}), 200
    except Exception as e:
        return jsonify({"error": "Failed to get last device ID", "details": str(e)}), 500


# Endpoint para deletar um dispositivo
@app.route('/device/delete', methods=['POST'])
def delete_device():
    data = request.get_json()
    id_device = data.get('id_device')

    if id_device is not None:
        success = db_delete_device(id_device)
        if success:
            return jsonify({"message": "Device deleted successfully"}), 200
        else:
            return jsonify({"error": "Device not found"}), 404
    else:
        return jsonify({"error": "id_device is required"}), 400


if __name__ == "__main__":
    app.run(debug=True)