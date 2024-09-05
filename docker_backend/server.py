from flask import Flask, request, jsonify
from flask_cors import CORS
import docker
import logging

app = Flask(__name__)
CORS(app)

client = docker.from_env()

@app.route('/run-script', methods=['POST'])
def run_script():
    container_id = request.json.get("container_id")
    script_command = request.json.get("script_command")

    if not container_id or not script_command:
        return jsonify({"error": "Resource ID or script command was not provided"}), 400

    try:
        container = client.containers.get(container_id)
        print(script_command)
        # Creiamo il comando da eseguire nel container
        exec_id = client.api.exec_create(container.id, cmd=script_command, stdout=True, stderr=True)

        # Eseguiamo il comando
        exec_result = client.api.exec_start(exec_id, stream=True)

        output = ''
        for line in exec_result:  # Raccogliamo l'output dallo stream
            output += line.decode('utf-8')  # Decodifica il byte stream in stringa

        logging.info(f"Command output: {output}")


        return output

    except Exception as e:
        logging.error(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
