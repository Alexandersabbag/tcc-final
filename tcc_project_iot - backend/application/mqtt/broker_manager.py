import subprocess
import time
import os

#Inicia o broker Mosquitto
def start_broker():
    global mqtt_process
    broker_path = r"C:\Program Files\mosquitto\mosquitto.exe"  # Caminho do executável do Mosquitto
    cmd = f'start cmd /k "cd /d "{os.path.dirname(broker_path)}" && mosquitto -v"'

    # Abre o CMD e inicia o broker
    mqtt_process = subprocess.Popen(cmd, shell=True)
    print("Iniciando broker ...")
    time.sleep(2)
    print("Broker iniciado.")
    return mqtt_process

#Finaliza o broker Mosquitto
def stop_broker():
    global mqtt_process
    print("Finalizando o broker...")
    time.sleep(1)
    cmd_kill_broker = 'taskkill /IM mosquitto.exe /F'
    cmd_close_cmd_window = f'taskkill /PID {mqtt_process.pid} /F'

    # Encerra o broker
    subprocess.Popen(cmd_kill_broker, shell=True)

    # Encerra o CMD que estava rodando o broker
    subprocess.Popen(cmd_close_cmd_window, shell=True)

    mqtt_process = None
    print("Broker e janela de comando encerrados.")