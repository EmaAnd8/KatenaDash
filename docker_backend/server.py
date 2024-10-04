import requests
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
import psycopg2



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


def verify_contract(contract_address):
    print("SONO NELLA FUNZIONE VERIFY_CONTRACT")

    contract_name = adminimpl
    """
    with open(file_path, 'r') as file:
        data = json.load(file)
    

    # Recupero del contract_name
    contract_name = data.get("contractName", none)
    if contract_name is None:
        raise KeyError("Campo 'contractName' non trovato nel file JSON")

    
    # Recupero del Metadata
    metadata = data.get("metadata", none)
    if contract_name is None:
        raise KeyError("Campo 'metadata' non trovato nel file JSON")
    """

    metadata = "{\"compiler\":{\"version\":\"0.5.7+commit.6da8b019\"},\"language\":\"Solidity\",\"output\":{\"abi\":[{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"token\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"LogWithdrawExcessTokens\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"marketId\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"token\",\"type\":\"address\"}],\"name\":\"LogAddMarket\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"marketId\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"isClosing\",\"type\":\"bool\"}],\"name\":\"LogSetIsClosing\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"marketId\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"priceOracle\",\"type\":\"address\"}],\"name\":\"LogSetPriceOracle\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"marketId\",\"type\":\"uint256\"},{\"indexed\":false,\"name\":\"interestSetter\",\"type\":\"address\"}],\"name\":\"LogSetInterestSetter\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"marketId\",\"type\":\"uint256\"},{\"components\":[{\"name\":\"value\",\"type\":\"uint256\"}],\"indexed\":false,\"name\":\"marginPremium\",\"type\":\"tuple\"}],\"name\":\"LogSetMarginPremium\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"marketId\",\"type\":\"uint256\"},{\"components\":[{\"name\":\"value\",\"type\":\"uint256\"}],\"indexed\":false,\"name\":\"spreadPremium\",\"type\":\"tuple\"}],\"name\":\"LogSetSpreadPremium\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"components\":[{\"name\":\"value\",\"type\":\"uint256\"}],\"indexed\":false,\"name\":\"marginRatio\",\"type\":\"tuple\"}],\"name\":\"LogSetMarginRatio\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"components\":[{\"name\":\"value\",\"type\":\"uint256\"}],\"indexed\":false,\"name\":\"liquidationSpread\",\"type\":\"tuple\"}],\"name\":\"LogSetLiquidationSpread\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"components\":[{\"name\":\"value\",\"type\":\"uint256\"}],\"indexed\":false,\"name\":\"earningsRate\",\"type\":\"tuple\"}],\"name\":\"LogSetEarningsRate\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"components\":[{\"name\":\"value\",\"type\":\"uint256\"}],\"indexed\":false,\"name\":\"minBorrowedValue\",\"type\":\"tuple\"}],\"name\":\"LogSetMinBorrowedValue\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"name\":\"operator\",\"type\":\"address\"},{\"indexed\":false,\"name\":\"approved\",\"type\":\"bool\"}],\"name\":\"LogSetGlobalOperator\",\"type\":\"event\"}],\"devdoc\":{\"author\":\"dYdX * Administrative functions to keep the protocol updated\",\"methods\":{},\"title\":\"AdminImpl\"},\"userdoc\":{\"methods\":{}}},\"settings\":{\"compilationTarget\":{\"project:/contracts/protocol/impl/AdminImpl.sol\":\"AdminImpl\"},\"evmVersion\":\"byzantium\",\"libraries\":{},\"optimizer\":{\"enabled\":true,\"runs\":10000},\"remappings\":[]},\"sources\":{\"openzeppelin-solidity/contracts/math/SafeMath.sol\":{\"keccak256\":\"0x965012d27b4262d7a41f5028cbb30c51ebd9ecd4be8fb30380aaa7a3c64fbc8b\",\"urls\":[\"bzzr://41ca38f6b0fa4b77b0feec43e422cfbec48b7eb38a41edf0b85c77e8d9a296b1\"]},\"project:/contracts/protocol/impl/AdminImpl.sol\":{\"keccak256\":\"0x6c37d2a0a51367c837224e8e56f8ccb30d8a51abd96f2280f25a5bd263b11bdf\",\"urls\":[\"bzzr://8d7208c7261de48b49450e12496db21b994d4b2bd8143842be2f9c78d7db1ce2\"]},\"project:/contracts/protocol/interfaces/IErc20.sol\":{\"keccak256\":\"0x6a972ae5d9fcb4e3f44589dc77ac3c168061c09a0a9001f29fdc2e361d044946\",\"urls\":[\"bzzr://e467ccb83dd015c9ca4862f3e95b7fd8c17c1cfd0a15a3dc799209967cf537ac\"]},\"project:/contracts/protocol/interfaces/IInterestSetter.sol\":{\"keccak256\":\"0xb675679876a8163f224dfc4f6598a168f8248400a49ab836fdd2a7f4d25a1683\",\"urls\":[\"bzzr://1597c0ec5015093d8d0a91af168e5e89c91ba615abc65048ed721195040ec0f8\"]},\"project:/contracts/protocol/interfaces/IPriceOracle.sol\":{\"keccak256\":\"0x647a7519803283e4152e0617881f0cf2766f8968cd1de9f28d624ee164adf19a\",\"urls\":[\"bzzr://0cb0053f7cfea2c823036aef20a99b63e5037fa9de5d55116a10374a45c7b828\"]},\"project:/contracts/protocol/lib/Account.sol\":{\"keccak256\":\"0x4c27c617b01972ddb8ca160454284ed09f3ec6f7abd667c31ca9f38805738d33\",\"urls\":[\"bzzr://ad0dd4229cea4f8c5b877a653766cf413d733e442cfc448ffd715e786d7b5216\"]},\"project:/contracts/protocol/lib/Cache.sol\":{\"keccak256\":\"0x5caa444f1798e385674713fef9b8190088f3a31655ae918340ff755e26566c82\",\"urls\":[\"bzzr://23b8e2e44d3db5588ff1311520e24272255f7b8d23c0923e955f51d5a4397beb\"]},\"project:/contracts/protocol/lib/Decimal.sol\":{\"keccak256\":\"0xfddbafc617a77d1db59ddbc596f6aa22931a9a656c0755887648c09bb038ae8c\",\"urls\":[\"bzzr://40396a3a6ded6bb9fe5b5c4b0318f7518ce23c925b104f557310a3775e6e383d\"]},\"project:/contracts/protocol/lib/Interest.sol\":{\"keccak256\":\"0x657f152e3853377ea93d101e145c2f2969fb6fbde025cedd10e7ee17c8bd5c4c\",\"urls\":[\"bzzr://ec53ea6522f8a1ae4150e1c8718f6d7d20d1755b93f4ee6268fd67bd979fa0f9\"]},\"project:/contracts/protocol/lib/Math.sol\":{\"keccak256\":\"0x05162cffa6d5479b6555e03af67b75e63d85272a3c3d3d2630a127ffa811ba41\",\"urls\":[\"bzzr://0e784dccf35201ef16030ec531028252d590936d75f0200f368a7e5981046af4\"]},\"project:/contracts/protocol/lib/Monetary.sol\":{\"keccak256\":\"0x6f876a958c45fb1f2cefce1d7ee0ceb610fbe393e0040ad2d5680e0aa5536e54\",\"urls\":[\"bzzr://8b027c6ce5cd901a634dab7de74d617098b706d50b1c2ea0636406e021ea2815\"]},\"project:/contracts/protocol/lib/Require.sol\":{\"keccak256\":\"0x6ecb512d52bb5cb36ba26b98877240e0b23eb3310df5dc61f82c655dc974d04b\",\"urls\":[\"bzzr://826485117e00106f438a7e64ecc32b2c3705e02d9bd6035dbdc5f9faaa19482c\"]},\"project:/contracts/protocol/lib/Storage.sol\":{\"keccak256\":\"0x862bb5cf49dd4415b2659d2815021bb97392d3bd11a32ae2803d9f85ecc947b4\",\"urls\":[\"bzzr://3c48763c77cfd222a379a7be791a4341f355e76f35bc4c62e16264fa0f71f23e\"]},\"project:/contracts/protocol/lib/Time.sol\":{\"keccak256\":\"0x6523f89764a33b986f6655b5a0fb5b375103153be606b07a9fa95ceb2b93c2f6\",\"urls\":[\"bzzr://61ff7be71d666649cf1b78c2d9950e0d58322932e7e5f6742adbe511e864cd51\"]},\"project:/contracts/protocol/lib/Token.sol\":{\"keccak256\":\"0x7fff4d94f462515466ed263d686abb7fff9b6d6c95a28662a64a8424f5d95a23\",\"urls\":[\"bzzr://41bc60c90477c5ddab82a7760c652d87cce21dadb00456e028ff37b849bd13f4\"]},\"project:/contracts/protocol/lib/Types.sol\":{\"keccak256\":\"0x35c04c154e9ef818a3e1b59eb748565645864d5f8f2bc696c1f425a8ade9ab00\",\"urls\":[\"bzzr://8b2db9cb583f79fc2b74a70b270667f6a3bc54c3afef6a2d56e0d2ec5b8ca725\"]}},\"version\":1}"

    url = f"http://localhost:4000/api/v2/smart-contracts/{contract_address}/verification/via/sourcify"

    # Invia la richiesta POST con il metadata
    response = requests.post(url, json=metadata)

    # Controlla la risposta
    if response.status_code == 200:
        print(f"Verifica completata con successo per il contratto {contract_name}: {contract_address}")
    else:
        print(f"Errore nella verifica per il contratto {contract_name} con address {contract_address}: {response.status_code}")
        print(response.text)


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

        # Recupero del contract_address
        # Definire un'espressione regolare per trovare le sezioni "Executing configure on" e i relativi contract_address
        pattern = r'Executing configure on (?P<registry>[^\s]+)\n.*?"contract_address":\s*"(?P<contract_address>0x[0-9a-fA-F]+)"'

        # Eseguire la ricerca con regex
        matches = re.finditer(pattern, output2)

        # Estrarre tutti i contract_address trovati
        for match in matches:
            contract_address = match.group('contract_address')

            registry = match.group('registry')
            registry_cleaned = registry.replace('_0', '').lower()

            # verify_contract({match.group('contract_address')}, metadata)

            print(f"Registry: {registry_cleaned}, Contract Address: {contract_address}")

            if "adminimpl" in registry_cleaned:
                print(f"TUTTO BENO CI SONO {registry_cleaned}")
                # verify_contract(contract_address)


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

