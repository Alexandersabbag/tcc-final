from datetime import datetime

def calculate_consumption(on_timestamp, off_timestamp, potencia):
    # Converte as strings de timestamp para objetos datetime
    on_time = datetime.strptime(on_timestamp, "%d/%m/%Y - %H:%M:%S")
    off_time = datetime.strptime(off_timestamp, "%d/%m/%Y - %H:%M:%S")

    # Calcula a diferença de tempo (off - on)
    duration = off_time - on_time
    total_seconds = duration.total_seconds()

    # Calcula o tempo total em horas, minutos e segundos
    hours = int(total_seconds // 3600)
    minutes = int((total_seconds % 3600) // 60)
    seconds = int(total_seconds % 60)
    duration_str = f"{hours:02}:{minutes:02}:{seconds:02}"

    # Calcula o consumo em watts-hora e converte para kWh
    consumption_wh = (float(potencia) * total_seconds) / 3600  # Consumo em watt-hora
    consumption_kwh = consumption_wh / 1000  # Conversão para kWh

    # Retorna o consumo e a duração formatada
    return round(consumption_kwh, 4), duration_str


def calculate_total_consumption(db_client):
    db = db_client['user_data']  # Nome do banco de dados
    logs_collection = db['logs']  # Coleção de logs

    # Recupera todos os documentos da coleção de logs
    logs = list(logs_collection.find())

    # Verifica se há registros na coleção de logs
    if not logs:
        print("Nenhum dispositivo ligado.")
        return

    total_consumption = 0  # Acumular o consumo total

    print("Detalhamento do consumo dos dispositivos:\n")

    for log in logs:
        device_on_id = log.get("id_on")
        device_off_id = log.get("id_off")
        consumption_entries = log.get("consumption", [])

        # Verifica se os dados estão completos antes de processar
        if not device_on_id or not device_off_id:
            continue

        # Itera sobre cada par ON/OFF e detalha o tempo e consumo
        for on_id, off_id, consumption in zip(device_on_id, device_off_id, consumption_entries):
            if on_id and off_id:
                # Pega as informações de tempo para ON e OFF dos tópicos
                on_entry = db['topics'].find_one({"_id": on_id})
                off_entry = db['topics'].find_one({"_id": off_id})

                # Extraindo timestamp dos documentos ON e OFF
                on_time = on_entry.get("timestamp")
                off_time = off_entry.get("timestamp")

                # Calcular o tempo em segundos para uma mensagem precisa
                duration_seconds = (off_time - on_time).total_seconds() if on_time and off_time else 0
                duration_hours = duration_seconds / 3600

                # Exibir informações detalhadas
                device_name = on_entry.get("topic", "Dispositivo Desconhecido").split('/')[-2]
                room_name = on_entry.get("topic", "Cômodo Desconhecido").split('/')[-3]

                print(f"{device_name} no(a) {room_name}")
                print(f"  Ligado de {on_time.strftime('%d/%m/%Y %H:%M:%S')} até {off_time.strftime('%d/%m/%Y %H:%M:%S')}")
                print(f"  Duração: {duration_hours:.2f} horas")
                print(f"  Consumo: {consumption:.4f} kWh\n")

                total_consumption += consumption

    print(f"Consumo total: {total_consumption:.4f} kWh")

