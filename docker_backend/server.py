from flask import Flask, request, jsonify
from flask_cors import CORS
import docker
import logging
import time
import threading

app = Flask(__name__)
CORS(app)
client = docker.from_env()
start_time = 0

# Funzione di monitoraggio del log
def monitor_log(exec_id3, stop_event, timeout, container):
    global start_time
    start_time = time.time()

    while not stop_event.is_set():
        if time.time() - start_time > timeout:
            print("No new data, stopping monitoring due to inactivity.")
            try:
                exec_info = client.api.exec_inspect(exec_id3)
                if exec_info['Running']:
                    exec_id2 = client.api.exec_create(container.id, cmd="pkill -f 'tail -f'", stdout=True, stderr=True)
                    client.api.exec_start(exec_id2, stream=True)
            except Exception as e:
                print(f"Error killing exec: {e}")
            break
        time.sleep(1)  # Pausa per evitare l'uso eccessivo della CPU


@app.route('/run-script', methods=['POST'])
def run_script():
    container_id = request.json.get("container_id")
    script_command = request.json.get("script_command")
    contentFile = request.json.get("content_yaml")
    global start_time

    if not container_id or not script_command:
        return jsonify({"error": "Resource ID or script command was not provided"}), 400

    try:
        container = client.containers.get(container_id)
        exec_id = client.api.exec_create(container.id, cmd=script_command, stdout=True, stderr=True)
        exec_result = client.api.exec_start(exec_id, stream=True)

        # Monitoraggio del file di log
        command = "tail -f deploy.log"
        exec_id3 = client.api.exec_create(container.id, cmd=['/bin/sh', '-c', command], stdout=True, stderr=True)
        exec_result3 = client.api.exec_start(exec_id3, stream=True)

        stop_event = threading.Event()
        timeout = 15  # Timeout in secondi
        monitor_thread = threading.Thread(target=monitor_log, args=(exec_id3, stop_event, timeout, container))
        monitor_thread.start()

        try:
            for line in exec_result3:
                decoded_line = line.decode('utf-8').strip()
                print(decoded_line)
                start_time = time.time()  # Assicurati che il timer venga aggiornato correttamente

        except Exception as e:
            print(f"Error during file monitoring: {e}")


        stop_event.set()
        monitor_thread.join()  # Aspetta che il thread termini


        output = ''
        for line in exec_result:  # Raccogliamo l'output dallo stream
            output += line.decode('utf-8')  # Decodifica il byte stream in stringa

        logging.info(f"Command output: {output}")

        exec_id2 = client.api.exec_create(container.id, cmd="cat deployment_results.txt", stdout=True, stderr=True)
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
    container_id = request.json.get("container_id")

    if not container_id:
        return jsonify({"error": "Resource ID was not provided"}), 400

    try:
        container = client.containers.get(container_id)
        exec_id = client.api.exec_create(container.id, cmd="lsof -i :8545 -t", stdout=True, stderr=True)
        exec_result = client.api.exec_start(exec_id, stream=True)

        output = ''
        for line in exec_result:  # Raccogliamo l'output dallo stream
            output += line.decode('utf-8').strip()  # Decodifica il byte stream in stringa

        exec_id2 = client.api.exec_create(container.id, cmd=f"kill -9 {output}", stdout=True, stderr=True)
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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)

