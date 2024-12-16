from application.databank.mongodb_connection import connect_to_mongodb
from datetime import datetime

from application.main.consumption import calculate_consumption

#Conexão com MongoDB
mongo_client = connect_to_mongodb()

#Banco de dados
db = mongo_client['user_data']

#Coleções
topics_collection = db['topics_history']
devices_collection = db['devices']
consumption_collection = db['consumption_logs']


# Insere os tópicos na coleção chamada "topics_history" do banco de dados
def db_add_topic(id_device, topic, timestamp, verify):
    try:
        # Criar o dicionário com apenas o campo 'topic'
        topic_history = {
            "id_device": id_device,
            "topic": topic,
            "timestamp": timestamp,
            "verify": verify
        }

        # Armazenar o tópico na coleção topics
        topics_collection.insert_one(topic_history)
        print("Tópico inserido com sucesso no banco de dados.")
        return "success"
    except Exception as e:
        print(f"Erro ao inserir o tópico no banco de dados: {e}")
        return "error"


# Atualiza o estado de dispositivo na coleção "devices"
def db_update_device(id_device, local, room, device, state):
    result = devices_collection.update_one(
        {"id_device": id_device,
         "local": local,
         "room": room,
         "device": device
         },  # Critério para encontrar o dispositivo
        {"$set": {"state": state}}  # Atualiza o estado do dispositivo
    )
    return result


# Adiciona um novo dispositivo na coleção "devices"
def db_add_device(new_device):
    try:
        result = devices_collection.insert_one(new_device)
        return result
    except Exception as e:
        print(f"Erro ao adicionar dispositivo: {e}")
        return None

# Função para calcular o consumo
def db_calculate_consumption():
    try:
        # Obtendo os dicionários
        topics_list = db_list_topics()
        topics_list.reverse()  # Inverter a ordem para que o mais recente venha primeiro
        devices_list = db_list_devices()

        # Estruturas para processar os dados
        topics_dict = {i: topic for i, topic in enumerate(topics_list, 1)}
        devices_dict = {i: device for i, device in enumerate(devices_list, 1)}

        # Loop para iterar em todos os dispositivos
        for device_id, device_data in devices_dict.items():
            id_device = device_data.get("id_device", None)
            device_name = device_data.get("device")
            if id_device is None:
                continue  # Pula caso id_device não exista no device

            # Busca em topics_dict por id_device correspondente
            topic_matches = [
                topic for topic in topics_dict.values()
                if isinstance(topic, dict) and topic.get("id_device") == id_device
            ]

            topic_matches = [
                topic for topic in topic_matches if topic.get("verify") == 0
            ]

            if not topic_matches:
                continue  # Pula se não houver nenhum tópico correspondente

            # Filtra pelos estados OFF e ON
            off_states = [topic for topic in topic_matches if topic.get("state") == "OFF"]
            on_states = [topic for topic in topic_matches if topic.get("state") == "ON"]

            if not off_states or not on_states:
                continue  # Pula se não houver pares ON/OFF

            selected_off = off_states[0]
            selected_on = on_states[0]

            # Recupera os timestamps e potência
            off_date_time = selected_off.get("date_time")
            on_date_time = selected_on.get("date_time")
            power = device_data.get("power")
            local = device_data.get("local")
            room = device_data.get("room")


            # Verifica se os campos necessários estão disponíveis
            if not all([off_date_time, on_date_time, power]):
                continue  # Pula se algum dado essencial estiver ausente

            # Calcula o consumo
            try:
                consumption, duration = calculate_consumption(on_date_time, off_date_time, power)
            except Exception as e:
                print(f"Erro no cálculo de consumo para id_device {id_device}: {e}")
                continue

            # Dados a serem salvos
            log_data = {
                "id_device": id_device,
                "on_date_time": on_date_time,
                "off_date_time": off_date_time,
                "duration": duration,
                "consumption_kwh": consumption,
                "power": power,
                "local": local,
                "room": room,
                "device": device_name
            }
            try:
                consumption_collection.insert_one(log_data)
                topics_collection.update_many(
                    {"id_device": id_device,
                     "$or": [{"topic": selected_on.get("topic")}, {"topic": selected_off.get("topic")}]},
                    {"$set": {"verify": 1}}
                )
                print(f"Log inserido com sucesso para id_device {id_device}: {log_data}")
            except Exception as e:
                print(f"Erro ao inserir log para id_device {id_device}: {e}")
        return "success"

    except Exception as e:
        print(f"Erro em db_calculate_consumption: {e}")


# Função para deletar os dispositivos
def db_delete_device(id_device):
    try:
        result = devices_collection.delete_one({"id_device": id_device})
        return result.deleted_count > 0
    except Exception as e:
        print(f"Erro ao deletar dispositivo: {e}")
        return False

#Função que calcula o consumo total
def db_total_consumption():
    try:
        logs = db_list_consumption_logs()
        total_consumption = sum(log.get('consumption_kwh', 0) for log in logs)
        return {"total_consumption": round(total_consumption, 4)}
    except Exception as e:
        print(f"Erro em db_total_consumption: {e}")
        return {"error": "Erro ao calcular o consumo total"}

# Lista todos os dispositivos armazenados na coleção "devices"
def db_list_devices():
    try:
        devices = list(devices_collection.find({}, {'_id': 0}))

        for device in devices:
            # Busca o estado mais recente na coleção device, baseado no dispositivo
            devices_data = devices_collection.find_one(
                {"local": device["local"], "room": device["room"], "device": device["device"]},
                sort=[("timestamp", -1)],  # Ordena para pegar o último estado
                projection={"state": 1, "_id": 0}
            )
            # Se houver o estado, adiciona ao dispositivo, caso contrário, define o estado como 'OFF'
            device["state"] = devices_data["state"] if devices_data else "off"

        return devices  # Retorna a lista de dispositivos já com o estado atualizado

    except Exception as e:
        print(f"Erro ao listar dispositivos: {e}")
        return []  # Retorna lista vazia em caso de erro


#Lista todos os tópicos em "topics_history"
def db_list_topics():
    try:
        topics = list(topics_collection.find({}, {'_id': 0, 'id_device': 1, 'topic': 1, 'timestamp': 1, 'verify': 1}))

        if not topics:
            return "no_topics_found"

        processed_topics = []
        for topic_data in topics:
            topic = topic_data.get('topic', '')
            timestamp = topic_data.get('timestamp', None)
            id_device = topic_data.get('id_device', None)
            verify = topic_data.get('verify', None)

            # Inicializar variáveis padrão
            local, room, device, state = '', '', '', ''

            # Extrair partes do campo 'topic'
            if topic:
                parts = topic.split('/')
                if len(parts) == 4:
                    local, room, device, state = parts

            # Processar timestamp
            date_time = "Invalid timestamp"  # Valor padrão em caso de erro
            if timestamp:
                try:
                    if isinstance(timestamp, int):
                        date_time = datetime.fromtimestamp(timestamp).strftime('%d/%m/%Y - %H:%M:%S')
                    elif isinstance(timestamp, float):
                        date_time = datetime.fromtimestamp(timestamp / 1000).strftime('%d/%m/%Y - %H:%M:%S')
                    elif isinstance(timestamp, str):  # String de data
                        try:
                            date_time = datetime.strptime(timestamp, '%Y-%m-%dT%H:%M:%S.%f').strftime('%d/%m/%Y - %H:%M:%S')
                        except ValueError:
                            date_time = datetime.strptime(timestamp, '%Y-%m-%dT%H:%M:%S').strftime('%d/%m/%Y - %H:%M:%S')
                    elif isinstance(timestamp, datetime):  # MongoDB Date
                        date_time = timestamp.strftime('%d/%m/%Y - %H:%M:%S')
                except Exception as e:
                    print(f"Erro ao processar timestamp: {e}")

            # Adicionar dados formatados à lista
            processed_topics.append({
                "local": local,
                "room": room,
                "device": device,
                "state": state,
                "topic": topic,
                "date_time": date_time,
                "id_device": id_device,
                "verify": verify,
            })

        return processed_topics

    except Exception as e:
        print(f"Erro ao listar tópicos: {e}")
        return None


#Listar toda a coleção "consumption_logs"
def db_list_consumption_logs():
    try:
        logs = list(consumption_collection.find())

        # Converte os documentos para um formato serializável (se necessário)
        for log in logs:
            log['_id'] = str(log['_id'])  # Converte o ObjectId para string
        return logs

    except Exception as e:
        print(f"Erro ao listar a coleção consumption_logs: {e}")
        return []


# Declaração de função para buscar logs de consumo
def db_get_consumption_logs():
    try:
        consumption_logs = list(consumption_collection.find({}, {'_id': 0}))
        return consumption_logs
    except Exception as e:
        print(f"Erro ao buscar logs de consumo: {e}")
        return None


# Busca o último id na coleção 'devices'
def db_get_last_device_id():
    try:
        # Encontrar o dispositivo com o maior id_device
        last_device = devices_collection.find_one({}, sort=[("id_device", -1)], projection={"id_device": 1})

        if last_device and "id_device" in last_device:
            return last_device["id_device"]
        else:
            return 0  # Se não houver dispositivos, retorna 1 para o primeiro dispositivo

    except Exception as e:
        print(f"Erro ao buscar o último id_device: {e}")
        return 0