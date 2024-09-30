from flask import Flask, request, jsonify
from flask_cors import CORS
import docker
import logging
import threading
import re
import websockets
import asyncio
from docker.errors import NotFound
import json
import sys

app = Flask(__name__)
CORS(app)
app.config['MAX_CONTENT_LENGTH'] = 100 * 1024 * 1024  # Limite a 100 MB
client = docker.from_env(timeout=120)
SIZE_CHUNK = 100

# Set per tenere traccia dei client connessi
clients = set()

# Docker
client = docker.from_env()
# Percorso alla cartella di dockerfile
dockerfile_dir = "../assets/katena-main"
image_name = "katena_image"
container_name = "katena_container"

def splitchuck(chunk):

    lines_in_chunk = chunk.split('\n')
    num_lines = len(lines_in_chunk)

    half_index = num_lines // 2

    first_half = lines_in_chunk[:half_index]
    second_half = lines_in_chunk[half_index:]

    first_half_chunk = "\n".join(first_half)
    second_half_chunk = "\n".join(second_half)

    byte_size1 = len(first_half_chunk.encode('utf-8'))
    byte_size2 = len(second_half_chunk.encode('utf-8'))

    kb_size1 = byte_size1 / 1024
    kb_size2 = byte_size2 / 1024

    if kb_size1 <= SIZE_CHUNK and kb_size2 <= SIZE_CHUNK:
        return [first_half_chunk, second_half_chunk]

    chunks = []
    if kb_size1 > SIZE_CHUNK:
        if len(first_half) > 1:
            chunks.extend(splitchuck(first_half_chunk))
        else:
            chunks.append(first_half_chunk)
    else:
        chunks.append(first_half_chunk)

    if kb_size2 > SIZE_CHUNK:
        if len(second_half) > 1:
            chunks.extend(splitchuck(second_half_chunk))
        else:
            chunks.append(second_half_chunk)
    else:
        chunks.append(second_half_chunk)

    return chunks

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


@app.route('/run-script', methods=['POST'])
def run_script():

    contentFile = request.json.get("content_yaml")

    contentJson = request.json.get("json_files")

    jsonContent = []

    for json_string in contentJson:
        jsonContent.append(json_string)


    container_id = client.containers.get(container_name).id

    try:

        # pulire il file di log
        command5 = "echo -n > deploy.log"
        clean_deploy = client.api.exec_create(container_id, cmd=['/bin/sh', '-c', command5])
        client.api.exec_start(clean_deploy)


        file_path_yaml = "benchmark/file_to_run.yaml"
        contentFile_escaped = contentFile.replace('"', '\\"')
        upload_command_yaml = f"printf \"%s\" \"{contentFile_escaped}\" > {file_path_yaml}"



        upload_file_yaml = client.api.exec_create(container_id, cmd=['/bin/sh', '-c', upload_command_yaml], stdout=True, stderr=True)
        client.api.exec_start(upload_file_yaml)


        for jsonFile in jsonContent:
            data = json.loads(jsonFile)

            contract_name = data.get("contractName")

            upload_command_json1 = f"touch nodes/temp_ABI/{contract_name}.json"
            upload_file_json1 = client.api.exec_create(container_id, cmd=['/bin/sh', '-c', upload_command_json1], stdout=True, stderr=True)
            client.api.exec_start(upload_file_json1)

            lines = jsonFile.splitlines()  # Divide la stringa per righe

            chunk_size = 2000

            file_path_json = f"nodes/temp_ABI/{contract_name}.json"




            for i in range(0, len(lines), chunk_size):
                chunk = "\n".join(lines[i:i + chunk_size])  # Unisci di nuovo le righe in una stringa
                chunk_escaped = chunk.replace("'", "'\\''")

                byte_size = len(chunk_escaped.encode('utf-8'))

                kb_size = byte_size / 1024

                chunks = []

                if kb_size > SIZE_CHUNK:
                    chunks = splitchuck(chunk_escaped)

                if chunks:
                    for mini_chunk in chunks:
                        upload_command_json = f"printf '%s\\n' '{mini_chunk}' >> {file_path_json}"
                        upload_file_json = client.api.exec_create(container_id, cmd=['/bin/sh', '-c', upload_command_json], stdout=True, stderr=True)
                        client.api.exec_start(upload_file_json)
                else:
                    upload_command_json = f"printf '%s\\n' '{chunk_escaped}' >> {file_path_json}"
                    upload_file_json = client.api.exec_create(container_id, cmd=['/bin/sh', '-c', upload_command_json], stdout=True, stderr=True)
                    client.api.exec_start(upload_file_json)


        exec_id = client.api.exec_create(container_id, cmd="/bin/sh -c ./run-deploy.sh", stdout=True, stderr=True)
        exec_result = client.api.exec_start(exec_id, stream=True)

        # Monitoraggio del file di log
        command = "tail -f deploy.log"
        exec_id3 = client.api.exec_create(container_id, cmd=['/bin/sh', '-c', command], stdout=True, stderr=True)
        exec_result3 = client.api.exec_start(exec_id3, stream=True)


        deploy_data = {
            'Deployment_of': []
        }

        deployment_of_pattern = r'\bDeployment of\s+(\w+)'  # Cattura la parola dopo "Deployment of"


        try:
            for line in exec_result3:
                decoded_line = line.decode('utf-8').strip()

                deployment_of_matches = re.findall(deployment_of_pattern, decoded_line)


                if deployment_of_matches:
                    # Memorizza la dimensione della lista prima di aggiungere
                    prev_len = len(deploy_data['Deployment_of'])

                    # Aggiungi le parole trovate al dizionario
                    deploy_data['Deployment_of'].extend(deployment_of_matches)

                    # Verifica se la dimensione è cambiata
                    if len(deploy_data['Deployment_of']) > prev_len:
                        asyncio.run(broadcast(str(deploy_data['Deployment_of'])))
                        print("Deployment of:", deploy_data['Deployment_of'])

                if "deploy finished" in decoded_line:
                    print("MAMMMAAAAAAAAAA")
                    exec_id2 = client.api.exec_create(container_id, cmd="pkill -f 'tail -f'")
                    client.api.exec_start(exec_id2)
                    break


        except Exception as e:
            print(f"Error during file monitoring: {e}")

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
        



        #return "A"

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
        exec_id = client.api.exec_create(container_id, cmd="./undeploy-bench.sh", stdout=True, stderr=True)
        exec_result = client.api.exec_start(exec_id, stream=True)

        output2 = ''
        for line in exec_result:  # Raccogliamo l'output dallo stream
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
            container = client.containers.run(image_name, name=container_name, stdin_open=True, tty=True, detach=True, ports={'8545':8545})
            container.reload()
            if container.status == "running":
                print(f"Container {container_name} avviato con successo!")
                exec_id = client.api.exec_create(container.id, cmd="chmod 777 run-deploy.sh deploy-bench.sh bootstrap-dev.sh deploy.log undeploy-bench.sh")
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

