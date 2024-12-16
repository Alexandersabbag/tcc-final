from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

def connect_to_mongodb():
    print("Conectando ao banco de dados...")
    uri = "mongodb+srv://alexandremsouza:Souza1997@cluster0.icjmc.mongodb.net/user_data?retryWrites=true&w=majority&appName=Cluster0"

    # Cria um novo cliente e conecta ao servidor
    db_client = MongoClient(uri, server_api=ServerApi('1'))

    # Envia um ping para confirmar a conexão
    try:
        db_client.admin.command('ping')
        print("Conectado com Sucesso ao MongoDB Atlas.")
        print("========================================================================================")
        return db_client
    except Exception as e:
        print(f"Erro ao conectar no MongoDB: {e}")
        return None

def disconnect_from_mongodb(db_client):
    try:
        db_client.close()
        print("Conexão com o MongoDB encerrada com sucesso.")
    except Exception as e:
        print(f"Erro ao encerrar a conexão com o MongoDB: {e}")