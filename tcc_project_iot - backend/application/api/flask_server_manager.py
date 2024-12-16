import subprocess, os, psutil

def start_flask_server():
    try:
        flask_file_path = r"D:\PycharmProjects\Iot_test\application\main\main.py"  # Substitua pelo caminho correto

        # Definindo as variáveis de ambiente do Flask
        os.environ['FLASK_APP'] = flask_file_path  # Substitua pelo nome do seu arquivo Flask
        os.environ['FLASK_ENV'] = 'development'  # Ambiente de desenvolvimento

        # Comando para rodar o servidor Flask
        command = "flask run --host=0.0.0.0 --port=8000"

        # Abre uma nova janela do CMD e executa o comando
        api_process = subprocess.Popen(f'start cmd /k "{command}"', shell=True)

        print("Servidor Flask iniciado.")
        return api_process
    except Exception as e:
        print(f"Erro ao iniciar o servidor Flask: {e}")

def stop_flask_server():
    try:
        # Encontrar o processo Flask em execução
        for proc in psutil.process_iter(attrs=['pid', 'name', 'cmdline']):
            if 'flask' in proc.info['cmdline']:
                # Enviar sinal de término para o processo Flask
                print(f"Parando o servidor Flask (PID: {proc.info['pid']})...")
                proc.terminate()  # Envia o sinal de término
                proc.wait()  # Espera o processo terminar
                print("Servidor Flask parado com sucesso.")
                break
        else:
            print("Servidor Flask não encontrado em execução.")
    except Exception as e:
        print(f"Erro ao parar o servidor Flask: {e}")