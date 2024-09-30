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
import 'dart:io';

Provider ServiceProvider = Provider.instance;
Widget simpleTopology = Container();

void _showAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Files missing'),
        content: Text("No files were uploaded corresponding to the following ABIs: \n" + message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Chiude il dialogo
            },
          ),
        ],
      );
    },
  );
}

void _showTemporaryPopup(BuildContext context) {
  // Mostra il pop-up come SnackBar
  const snackBar = SnackBar(
    content: Text('You did not enter the topology file'),
    duration: Duration(seconds: 3), // Imposta la durata a 1 secondo
  );

  // Mostra il SnackBar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


class DeployBody extends StatefulWidget {
  const DeployBody({super.key});

  @override
  _DeployState createState() => _DeployState();
}

class _DeployState extends State<DeployBody> {
  String? selectedOption; // Allow null for no selection
  String _dynamicText = "Deploy a new topology..."; // Variabile per il testo dinamico
  Map<String, List<PlatformFile>> filesMap = {
    'yaml': [],
    'json': [],
  };
  // contatore dei nodi
  int nodeCount = 0;

  WebSocketChannel? _channel;
  List<String> _items = [];
  double _percentageValue = 0.0;
  bool progressBool = false;
  bool _buttonDeploy = false;
  bool _buttonWithdraw = true;


  @override
  void initState() {
    super.initState();
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
          _percentageValue = (_items.length / nodeCount).toDouble();
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


  int _countTopologyTemplateNodes(dynamic topologyTemplate) {
    // Funzione ricorsiva per contare i nodi
    int count = 0;

    if (topologyTemplate is YamlMap) {
      // Controlla se c'è la chiave node_templates
      if (topologyTemplate['node_templates'] is YamlMap) {
        count += (topologyTemplate['node_templates'].length as int); // Conta i nodi in node_templates
      }
    }

    return count;
  }

  List<String> extractAbis(dynamic data) {
    List<String> abiList = [];

    // Controlla se i dati sono una mappa
    if (data is Map) {
      data.forEach((key, value) {
        if (key == 'abi' && value is String) {
          abiList.add(value);
        } else {
          abiList.addAll(extractAbis(value)); // Ricorsione per esplorare ulteriormente
        }
      });
    } else if (data is List) {
      for (var item in data) {
        abiList.addAll(extractAbis(item)); // Ricorsione per ogni elemento della lista
      }
    }

    return abiList;
  }

  bool _checkABI(){

    var contents = String.fromCharCodes(filesMap['yaml']!.first.bytes!.toList());

    var yamlData = loadYaml(contents);

    List<String> abiList = extractAbis(yamlData);

    List<String> listERROR = [];

    // Controlla ogni elemento in abiList
    for (var abi in abiList) {
      // Controlla se il file corrispondente esiste in filesMap['json']
      bool exists = filesMap['json']!.any((file) => file.name.replaceAll('.json', '') == abi);

      // Se non esiste, aggiungilo a listERROR
      if (!exists) {
        listERROR.add(abi);
      }
    }

    if (listERROR.isNotEmpty){
      String finalErrorString = listERROR.join(', ');

      _showAlertDialog(context, finalErrorString);

      return false;
    }

    return true;


  }

  Future<void> _pickFile() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['yaml', 'json'],
    );

    if (result != null) {
      filesMap['yaml']!.clear();
      filesMap['json']!.clear();
      for (var file in result.files) {
        if (file.extension == 'yaml') {
          filesMap['yaml']!.add(file);
        } else if (file.extension == 'json') {
          filesMap['json']!.add(file);
        }
      }


      if (filesMap['yaml']!.isEmpty) {
        _showTemporaryPopup(context);
        filesMap['json']!.clear();
        setState(() {
          _fileName = null;
          _buttonDeploy = false;
        });
      } else {
        print('File YAML selezionato: ${filesMap['yaml']!.first.name}');

        var contents = String.fromCharCodes(filesMap['yaml']!.first.bytes!.toList());

        var yamlData = loadYaml(contents);

        // Contare i nodi nella sezione topology_template
        if (yamlData['topology_template'] != null) {
          nodeCount = _countTopologyTemplateNodes(yamlData['topology_template']);
        }

        print(nodeCount);

        if(filesMap['json']!.isEmpty){
        setState(() {
          _fileName =  filesMap['yaml']!.first.name;
          _buttonDeploy = true;
        });
         } else {
          setState(() {
            _fileName =  filesMap['yaml']!.first.name + " and " + filesMap['json']!.length.toString() + ' file json';
            _buttonDeploy = true;
          });
        }
      }

      if (filesMap['json']!.isNotEmpty) {
        print('File JSON selezionati:');
        for (var jsonFile in filesMap['json']!) {
          print(jsonFile.name);
        }
      }
    } else {
      // L'utente ha annullato la selezione dei file
      print("Nessun file selezionato.");
    }


  }

  Future<void> _sendRequest() async {

    setState(() {
      _buttonDeploy = false;
      _buttonWithdraw = false;
    });

    if(!_checkABI()){
      setState(() {
        _buttonWithdraw = true;
      });
      return;
    }

    progressBool=true;


    final url = Uri.parse('http://localhost:5001/run-script');

    _updateText("Deploying...");

    _connectToWebSocket();

    var contentYaml = String.fromCharCodes(filesMap['yaml']!.first.bytes!.toList());

    List<String> jsonContents = filesMap['json']!
        .map((file) => String.fromCharCodes(file.bytes!))
        .toList();

    int totalBytes = jsonContents.fold(0, (sum, content) => sum + utf8.encode(content).length);


    print("Total size in bytes: $totalBytes");

    print(jsonContents.length);



    final requestBody = jsonEncode(<String, dynamic>{
      'content_yaml': contentYaml,
      'json_files': jsonContents,
    });


    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final String output = response.body;
      _updateText(output);
      setState(() {
        _percentageValue = 1;
        _buttonWithdraw = true;
      });
    } else {
      final String error = response.body;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
      _updateText(error);
      setState(() {
        _buttonWithdraw = true;
      });
    }
  }

  Future<void> _withdrawRequest() async {
    _percentageValue=0.0;
    progressBool=false;
    final url = Uri.parse('http://localhost:5001/withdraw');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    filesMap['yaml']!.clear();
    filesMap['json']!.clear();

    setState(() {
      _fileName = null;
      _buttonDeploy = false;
    });


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

          Stack(
            alignment: Alignment.center, // Allinea i widget al centro
            children: <Widget>[
              if(progressBool)
                  CircularProgressIndicator(
                    value: _percentageValue,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    strokeWidth: 5.0,
                  ),
                  if(progressBool)
                  Text(
                    (_percentageValue*100).floorToDouble().clamp(0, 100).toString() + '%',
                    style: TextStyle(fontSize: 12, color: Colors.blueAccent), // Puoi cambiare il colore se necessario
                  ),
            ],

          ),

          const SizedBox(width: 10), // Spazio tra i pulsanti
          TextButton(
            onPressed: _buttonDeploy ? _sendRequest : null,
            style: TextButton.styleFrom(
              backgroundColor: Colors.green, // Colore verde
              foregroundColor: Colors.white, // Colore del testo
            ),
            child: const Text('Deploy'),
          ),
          const SizedBox(width: 8), // Spazio tra i pulsanti
          TextButton(
            onPressed: _buttonWithdraw ? _withdrawRequest : null,
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
                    const Padding(
                      padding: EdgeInsets.all(1.0),
                      child: Text(
                        'Insert the topology file and all files required for proper deployment',
                        style: TextStyle(
                          fontSize: 14,
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
                            onPressed: _pickFile,
                            child: const Text('Pick File...'),
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
