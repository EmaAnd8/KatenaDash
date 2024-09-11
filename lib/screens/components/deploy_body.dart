import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/topology/topologymanangement/topology_management_screen.dart';
import 'package:katena_dashboard/screens/topology/topologyview/topology_view_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding and decoding
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';




Provider ServiceProvider = Provider.instance;
Widget simpleTopology = Container();

class DeployBody extends StatefulWidget {
  const DeployBody({super.key});

  @override
  _DeployState createState() => _DeployState();
}

class _DeployState extends State<DeployBody> {
  String? selectedOption; // Allow null for no selection
  String _dynamicText = "Deploy a new topology..."; // Variabile per il testo dinamico

  WebSocketChannel? _channel;
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8765'),
    );

    _channel?.stream.listen(
          (message) {
        setState(() {
          var items = message.replaceAll(RegExp(r"[\[\]']"), '');
          _items = items.split(',');
        });
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }


  String? _fileName;
  String contentFile = "A";


  void _controllPickFile() async {
    contentFile = await _pickFile();
    print(contentFile);
  }

  Future<String> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['yaml'],
    );

    if (result != null) {
      try {
        setState(() {
          _fileName = result.files.single.name;
        });
        PlatformFile file = result.files.single;
        final yamlString = utf8.decode(file.bytes!);
        return yamlString;
      } catch (e) {
        print(e);
      }
    } else {
      //do nothing
      print("no file selected");
    }

    return "a";
  }

  Future<void> _sendRequest() async {
    final url = Uri.parse('http://localhost:5001/run-script');
    _updateText("Deploying...");
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'container_id': '12cfd61cb30f',
        'script_command': '/bin/sh -c ./run-deploy.sh',
        'content_yaml': contentFile,
      }),
    );

    if (response.statusCode == 200) {
      final String output = response.body;
      _updateText(output);
    } else {
      final String error = response.body;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
      _updateText(error);
    }
  }

  Future<void> _withdrawRequest() async {
    final url = Uri.parse('http://localhost:5001/withdraw');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'container_id': '12cfd61cb30f',
      }),
    );

    if (response.statusCode == 200) {
      final String output = response.body;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Output: $output')));
      _updateText("Deploy a new topology...");
      _items.clear();
    } else {
      final String error = response.body;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
      print(error);
    }
  }

  void _updateText(String result) {
    setState(() {
      _dynamicText = result;
    });
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deploy Viewer'),
        centerTitle: true,
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return HomeScreen();
              }),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: _sendRequest,
            style: TextButton.styleFrom(
              backgroundColor: Colors.green, // Colore verde
              foregroundColor: Colors.white, // Colore del testo
            ),
            child: const Text('Deploy'),
          ),
          const SizedBox(width: 8), // Spazio tra i pulsanti
          TextButton(
            onPressed: _withdrawRequest,
            style: TextButton.styleFrom(
              backgroundColor: Colors.red, // Colore rosso
              foregroundColor: Colors.white, // Colore del testo
            ),
            child: const Text('Withdraw'),
          ),
          PopupMenuButton<String>(
            onSelected: (String item) {
              setState(() {
                selectedOption = item;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: '1',
                  child: Text('Make the Deploy'),
                  onTap: () async {
                    // Uncomment and implement if needed
                    // simpleTopology = await ServiceProvider.CreateNode();
                    // setState(() {
                    //   simpleTopology;
                    // });
                  },
                ),
                PopupMenuItem<String>(
                  value: '2',
                  child: Text('Edit your Topology'),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) {
                          return TopologyManagementScreen();
                        }), (route) => false);
                  },
                ),
                PopupMenuItem<String>(
                  value: '3',
                  child: Text('View a Topology'),
                  onTap: () async {
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) {
                          return TopologyViewScreen();
                        }), (route) => false);
                  },
                ),
              ];
            },
            icon: Icon(Icons.menu),
          ),
        ],
      ),
      body: Container(
        width: size.width,
        height: size.height,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'File selection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: _controllPickFile,
                            child: Text('Pick File...'),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _fileName ?? 'No file selected',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: size.width,
                height: 1000,
                child: GridView.count(
                  crossAxisCount: 2,  // Due colonne
                  crossAxisSpacing: 8.0,  // Spazio orizzontale tra le colonne
                  mainAxisSpacing: 8.0,  // Spazio verticale tra le righe
                  padding: EdgeInsets.all(8.0),  // Padding generale per la GridView
                  children: [
                    Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Deployment Log',
                              style: TextStyle(
                                fontSize: 18.0, // Font size for the title
                                fontWeight: FontWeight.bold, // Make title bold
                                color: Colors.white, // Title color
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0), // Space between title and content
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                _dynamicText,
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white, // Set background color if needed
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Deployment Status',
                              style: TextStyle(
                                fontSize: 18.0, // Font size for the title
                                fontWeight: FontWeight.bold, // Make title bold
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0), // Space between title and items
                          ..._items.map((item) {
                            return Text(
                              'Deployment of $item complete',
                              style: TextStyle(
                                color: Colors.green, // Text color
                                fontSize: 16.0, // Text size
                                fontWeight: FontWeight.bold, // Make text bold
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
