import time

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print(f'Cliente conectado com sucesso!')
        dynamic_topic = userdata.get("user_topic", "/default/topic")
        print(f'tópico inscrito: {dynamic_topic}')
        client.subscribe(dynamic_topic)
    else:
        print(f'Erro ao conectar, código= {rc}')
    print("================================================================================================")

def on_subscribe(client, userdata, mid, granted_qos):
    print("\n")
    print(f"Inscrição bem-sucedida: {mid}, QoS concedido: {granted_qos}")
    print("================================================================================================")
    time.sleep(2)

def on_message(client, userdata, message):
    print('============================ Mensagem recebida ============================')
    print(f'Tópico: {message.topic}')
    print(f'Mensagem: {message.payload.decode()}')
    print("================================================================================================")
    time.sleep(2)
