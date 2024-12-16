import paho.mqtt.client as mqtt
from application.mqtt.callbacks import on_connect, on_message, on_subscribe

class MqttClientConnection:
    def __init__(self, broker_ip:str, port:int, client_name: str, keepalive=60):
        self._broker_ip = broker_ip
        self._port = port
        self._client_name= client_name
        self._keepalive = keepalive
        self._mqtt_client = None

    # Começa a conexão e inscreve o cliente nos tópicos
    def start_connection(self, topic):
        # Configura o cliente MQTT
        mqtt_client = mqtt.Client(self._client_name)

        # parâmetros passado pelo cliente
        mqtt_client.user_data_set({"user_topic": topic})

        # Callbacks
        mqtt_client.on_connect = on_connect
        mqtt_client.on_subscribe = on_subscribe
        mqtt_client.on_message = on_message

        # Conectando ao broker
        mqtt_client.connect(host=self._broker_ip, port=self._port, keepalive=self._keepalive)
        self._mqtt_client = mqtt_client
        mqtt_client.loop_start()

        # Cliente se inscreve no tópico
        mqtt_client.subscribe(topic)

    # Termina a conexão do cliente
    def end_connection(self):
        if self._mqtt_client is not None:
            try:
                self._mqtt_client.loop_stop()
                self._mqtt_client.disconnect()
                return True
            except Exception as e:
                print(f"Erro ao encerrar a conexão: {e}")
                return False
        return False

    @property
    def mqtt_client(self):
        return self._mqtt_client