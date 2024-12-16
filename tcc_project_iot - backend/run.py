from application.mqtt.broker_manager import start_broker, stop_broker
from application.api.flask_server_manager import start_flask_server, stop_flask_server

if __name__ == "__main__":
    start_broker()  # Inicia o broker MQTT
    start_flask_server() # inicia o servidor flask