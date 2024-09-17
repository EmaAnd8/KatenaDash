from flask import Flask, request, jsonify
from flask_cors import CORS
import docker
import logging
import time
import threading
import re
import websockets
import asyncio
from docker.errors import NotFound
import os

app = Flask(__name__)
CORS(app)
client = docker.from_env(timeout=120)
start_time = 0

# Set per tenere traccia dei client connessi
clients = set()

# Docker
client = docker.from_env()
# Percorso alla cartella di dockerfile
dockerfile_dir = "../assets/katena-main"
image_name = "katena_image"
container_name = "katena_container"

async def broadcast(message):
    if clients:  # Invia solo se ci sono client connessi
        await asyncio.gather(*[client.send(message) for client in clients])

async def register(websocket, path):  # Aggiungi 'path' come secondo argomento
    clients.add(websocket)
    try:
        print("Client connected")
        async for message in websocket:
            print(f"Received message: {message}")
    except websockets.ConnectionClosedError as e:
        print(f"Connection closed with error: {e}")
    finally:
        clients.remove(websocket)
        print("Client disconnected")

async def start_websocket_server():
    async with websockets.serve(register, "localhost", 8765):
        print("Server WebSocket in ascolto su ws://localhost:8765")
        await asyncio.Future()  # Mantiene il server in esecuzione




# Funzione di monitoraggio del log
def monitor_log(exec_id3, stop_event, timeout, container):
    global start_time
    start_time = time.time()

    while not stop_event.is_set():
        print(f"{time.time() - start_time }")
        if time.time() - start_time > timeout:
            print("No new data, stopping monitoring due to inactivity.")
            try:
                exec_info = client.api.exec_inspect(exec_id3)
                if exec_info['Running']:
                    exec_id2 = client.api.exec_create(container, cmd="pkill -f 'tail -f'", stdout=True, stderr=True)
                    client.api.exec_start(exec_id2, stream=True)
            except Exception as e:
                print(f"Error killing exec: {e}")
            break
        time.sleep(1)  # Pausa per evitare l'uso eccessivo della CPU



@app.route('/run-script', methods=['POST'])
def run_script():
    script_command = request.json.get("script_command")
    contentFile = request.json.get("content_yaml")
    global start_time
    # assegno il container id creato
    container_id = client.containers.get(container_name).id
    if not container_id or not script_command:
        return jsonify({"error": "Resource ID or script command was not provided"}), 400

    try:
        # pulire il file di log
        command5="echo -n > deploy.log"
        exec_log_clean = client.api.exec_create(container_id, cmd=['/bin/sh', '-c', command5])
        client.api.exec_start(exec_log_clean)

        #print(contentFile)
        file_path5 = "benchmark/file_to_run.yaml"
        contentFile_escaped = contentFile.replace('"', '\\"')
        command3 = f"printf \"%s\" \"{contentFile_escaped}\" > {file_path5}"


#print(command)

        exec_id7 = client.api.exec_create(container_id, cmd=['/bin/sh', '-c', command3], stdout=True, stderr=True)
        client.api.exec_start(exec_id7)


        time.sleep(1)


        exec_id = client.api.exec_create(container_id, cmd=script_command, stdout=True, stderr=True)
        exec_result = client.api.exec_start(exec_id, stream=True)

        # Monitoraggio del file di log
        command = "tail -f deploy.log"
        exec_id3 = client.api.exec_create(container_id, cmd=['/bin/sh', '-c', command], stdout=True, stderr=True)
        exec_result3 = client.api.exec_start(exec_id3, stream=True)



        stop_event = threading.Event()
        timeout = 40  # Timeout in secondi
        monitor_thread = threading.Thread(target=monitor_log, args=(exec_id3, stop_event, timeout, container_id))
        monitor_thread.start()

        deploy_data = {
            #'Deploying': [],
            'Deployment_of': []
        }

        #deploying_pattern = r'\bDeploying\s+(\w+)'  # Cattura la parola dopo "Deploying"
        deployment_of_pattern = r'\bDeployment of\s+(\w+)'  # Cattura la parola dopo "Deployment of"


        try:
            for line in exec_result3:
                decoded_line = line.decode('utf-8').strip()

                #deploying_matches = re.findall(deploying_pattern, decoded_line)
                print(f"{decoded_line}")

                deployment_of_matches = re.findall(deployment_of_pattern, decoded_line)

                # Aggiungi le parole trovate al dizionario
                #deploy_data['Deploying'].extend(deploying_matches)

                if deployment_of_matches:
                    # Memorizza la dimensione della lista prima di aggiungere
                    prev_len = len(deploy_data['Deployment_of'])

                    # Aggiungi le parole trovate al dizionario
                    deploy_data['Deployment_of'].extend(deployment_of_matches)

                    # Verifica se la dimensione è cambiata
                    if len(deploy_data['Deployment_of']) > prev_len:
                        asyncio.run(broadcast(str(deploy_data['Deployment_of'])))
                        print("Deployment of:", deploy_data['Deployment_of'])
                start_time = time.time()  # Assicurati che il timer venga aggiornato correttamente

        except Exception as e:
            print(f"Error during file monitoring: {e}")

        #print("Deploying:", deploy_data['Deploying'])
        #print("Deployment of:", deploy_data['Deployment_of'])
        stop_event.set()
        monitor_thread.join()  # Aspetta che il thread termini


        output = ''
        for line in exec_result:  # Raccogliamo l'output dallo stream
            output += line.decode('utf-8')  # Decodifica il byte stream in stringa

        logging.info(f"Command output: {output}")

        exec_id2 = client.api.exec_create(container_id, cmd="cat deployment_results.txt", stdout=True, stderr=True)
        exec_result2 = client.api.exec_start(exec_id2, stream=True)

        output2 = ''
        for line in exec_result2:  # Raccogliamo l'output dallo stream
            output2 += line.decode('utf-8')  # Decodifica il byte stream in stringa

        return output2

    except Exception as e:
        logging.error(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route('/withdraw', methods=['POST'])
def withdraw():
    # assegno il container id creato
    container_id = client.containers.get(container_name).id
    if not container_id:
        return jsonify({"error": "Resource ID was not provided"}), 400

    try:
        exec_id = client.api.exec_create(container_id, cmd="lsof -i :8545 -t", stdout=True, stderr=True)
        exec_result = client.api.exec_start(exec_id, stream=True)

        output = ''
        for line in exec_result:  # Raccogliamo l'output dallo stream
            output += line.decode('utf-8').strip()  # Decodifica il byte stream in stringa

        exec_id2 = client.api.exec_create(container_id, cmd=f"kill -9 {output}", stdout=True, stderr=True)
        exec_result2 = client.api.exec_start(exec_id2, stream=True)

        output2 = ''
        for line in exec_result2:  # Raccogliamo l'output dallo stream
            output2 += line.decode('utf-8').strip()  # Decodifica il byte stream in stringa

        logging.info(f"Command output: {output2}")
        print(output2)

        return output2

    except Exception as e:
        logging.error(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500


def run_flask_server():
    app.run(host='0.0.0.0', port=5001)


# Funzione di creazione dell'immagine Docker
def build_image():
    try:
        # Controlla se l'immagine esiste
        client.images.get(image_name)
        print(f"L'immagine {image_name} esiste già.")
    except NotFound:
        print(f"L'immagine {image_name} non trovata. Creazione in corso...")
        try:
            # Costruisce l'immagine
            image = client.images.build(path=dockerfile_dir, tag=image_name, rm=True, forcerm=True)

            # Pulizia docker
            # Rimuovere i container temporanei creati durante la build
            print("Rimozione dei container temporanei creati durante la build...")

            print(f"Immagine {image_name} creata con successo!")
        except Exception as e:
            print(f"Errore durante la creazione dell'immagine: {e}")

# Funzione di creazione del container Docker
def create_and_run_container():
    try:
        # Controlla se il container esiste
        existing_containers = client.containers.list(all=True, filters={"name": container_name})

        if existing_containers:
            container = existing_containers[0]

            if container.status == "running":
                print(f"Il container {container_name} è già in esecuzione.")
            else:
                print(f"Il container {container_name} esiste ma non è in esecuzione. Avvio in corso...")
                container.start()
                container.reload()
                if container.status == "running":
                    print(f"Il container {container_name} è stato avviato correttamente.")
                else:
                    print(f"Il container {container_name} NON è stato avviato correttamente.")

        else:
            print(f"Il container {container_name} non esiste. Creazione e avvio in corso...")
            # Crea e avvia il container
            container = client.containers.run(image_name, name=container_name, stdin_open=True, tty=True, detach=True)
            container.reload()
            if container.status == "running":
                print(f"Container {container_name} avviato con successo!")
                exec_id = client.api.exec_create(container.id, cmd="chmod 777 run-deploy.sh deploy-bench.sh bootstrap-dev.sh deploy.log")
                client.api.exec_start(exec_id)
            else:
                print(f"Container {container_name} NON avviato con successo!")


    except Exception as e:
        print(f"Errore durante la creazione o l'avvio del container: {e}")



if __name__ == '__main__':
    # Docker
    build_image()
    create_and_run_container()

    websocket_thread = threading.Thread(target=lambda: asyncio.run(start_websocket_server()))
    websocket_thread.start()

    # Avvia il server Flask
    run_flask_server()

