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
    logging.info(f"Received request with container_id: {container_id} and script_command: {script_command}")

    if not container_id or not script_command:
        return jsonify({"error": "Resource ID or script command was not provided"}), 400

    try:
        container = client.containers.get(container_id)

        exec_id = client.api.exec_create(container.id, cmd=script_command, stdout=True, stderr=True)
        exec_result = client.api.exec_start(exec_id, stream=False)

        #print(exec_result.)

        #output = exec_result.output.decode('utf-8')
        #error = exec_result.stderr.decode('utf-8')

        #logging.info(f"Command output: {output}")
        #if error:
        #    logging.error(f"Command error: {error}")

        return 200 #jsonify({"output": output, "error": error}), 200
    except Exception as e:
        logging.error(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
