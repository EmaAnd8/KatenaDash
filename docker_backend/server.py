import requests
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
app.config['MAX_CONTENT_LENGTH'] = 100 * 1024 * 1024  # 100 MB limits
client = docker.from_env(timeout=120)
SIZE_CHUNK = 100

# Set to keep track of connected clients
clients = set()

# Docker
client = docker.from_env()
# Path for dockerfile directory
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
    if clients:  # Send only if there are clients connected
        await asyncio.gather(*[client.send(message) for client in clients])

async def register(websocket, path):
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
        print("WebSocket server listening on ws://localhost:8765")
        await asyncio.Future()  # Keeps the server running


def verify_contract(contract_address, contract_name, sol_content):
    # API endpoint for contract verification on Blockscout
    url = f"http://localhost:80/api/v2/smart-contracts/{contract_address}/verification/via/multi-part"

    # Parameters needed for verification
    data = {
        "license": "MIT",  # Contract License
        "compilerVersion": "v0.8.0+commit.c7dfd78e",  # Compiler version
        "evmVersion": "Istanbul", # EVM version
        "optimizationUsed": "0",
        "constructorArguments": "",
        "contractName": contract_name  # Contract name
    }

    # File check referring to contract_name and conversion to bytes
    sol_content_bytes = None
    for sol_file in sol_content:
        name = re.search(r'contract\s+(\w+)', sol_file).group(1).lower()
        if contract_name.lower() == name:
            sol_content_bytes = sol_file.encode('utf-8')
            break

    if sol_content_bytes is None:
        print("Contract not found in Solidity list.")
        return

    files = {
        "sourceCode": (f"{contract_name}.sol", sol_content_bytes),
    }
    print(f"Sto inviando la richiesta HTTP del {contract_name} con il file:")
    response = requests.post(url, data=data, files=files)

    # Check the request response
    if response.status_code == 200:
        print("Successfully verified contract!")
    else:
        print(f"Error in contract verification: {response.status_code}")
        print(response.text)


@app.route('/run-script', methods=['POST'])
def run_script():

    contentFile = request.json.get("content_yaml")

    contentJson = request.json.get("json_files")

    contentSol = request.json.get("sol_files")

    jsonContent = []

    for json_string in contentJson:
        jsonContent.append(json_string)

    solContent = []

    for sol_string in contentSol:
        solContent.append(sol_string)

    container_id = client.containers.get(container_name).id

    try:
        # Clean the log file
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

            lines = jsonFile.splitlines()  # Divides the string by rows
            chunk_size = 2000
            file_path_json = f"nodes/temp_ABI/{contract_name}.json"

            for i in range(0, len(lines), chunk_size):
                chunk = "\n".join(lines[i:i + chunk_size])  # Merge the rows back into a string
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

        # Monitoring the log file
        command = "tail -f deploy.log"
        exec_id3 = client.api.exec_create(container_id, cmd=['/bin/sh', '-c', command], stdout=True, stderr=True)
        exec_result3 = client.api.exec_start(exec_id3, stream=True)

        deploy_data = {
            'Deployment_of': []
        }

        deployment_of_pattern = r'\bDeployment of\s+(\w+)'  # Capture the word after “Deployment of”

        try:
            for line in exec_result3:
                decoded_line = line.decode('utf-8').strip()

                deployment_of_matches = re.findall(deployment_of_pattern, decoded_line)

                if deployment_of_matches:
                    # Stores the size of the list before adding
                    prev_len = len(deploy_data['Deployment_of'])

                    # Add found words to the dictionary
                    deploy_data['Deployment_of'].extend(deployment_of_matches)

                    # Check if the size has changed
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
        for line in exec_result:  # We collect the output from the stream
            output += line.decode('utf-8')  # Decode byte stream into string

        logging.info(f"Command output: {output}")

        exec_id2 = client.api.exec_create(container_id, cmd="cat deployment_results.txt", stdout=True, stderr=True)
        exec_result2 = client.api.exec_start(exec_id2, stream=True)

        output2 = ''
        for line in exec_result2:  # We collect the output from the stream
            output2 += line.decode('utf-8')  # Decode byte stream into string

        # Recovery of contract_address
        # Define a regular expression to find “Executing configure on” sections and their contract_addresses
        pattern = r'Executing configure on (?P<registry>[^\s]+)\n.*?"contract_address":\s*"(?P<contract_address>0x[0-9a-fA-F]+)"'

        # Perform search with regex
        matches = re.finditer(pattern, output2)

        # Extract all contract_addresses found
        for match in matches:
            contract_address = match.group('contract_address')

            registry = match.group('registry')
            contract_name = registry.replace('_0', '').lower()

            # Function for verify the contract by contract address, contract name and .sol file
            verify_contract(contract_address, contract_name, solContent)

        return output2

    except Exception as e:
        logging.error(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route('/withdraw', methods=['POST'])
def withdraw():
    # Assignment of the created container id
    container_id = client.containers.get(container_name).id
    if not container_id:
        return jsonify({"error": "Resource ID was not provided"}), 400

    try:
        exec_id = client.api.exec_create(container_id, cmd="./undeploy-bench.sh", stdout=True, stderr=True)
        exec_result = client.api.exec_start(exec_id, stream=True)

        output2 = ''
        for line in exec_result:  # Collect the output from the stream
            output2 += line.decode('utf-8').strip()  # Decode byte stream into string

        logging.info(f"Command output: {output2}")
        print(output2)

        return output2

    except Exception as e:
        logging.error(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500


def run_flask_server():
    app.run(host='0.0.0.0', port=5001)




if __name__ == '__main__':

    websocket_thread = threading.Thread(target=lambda: asyncio.run(start_websocket_server()))
    websocket_thread.start()

    # Flask server start
    run_flask_server()

