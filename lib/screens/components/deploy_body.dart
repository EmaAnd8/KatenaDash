import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/topology/topologymanangement/topology_management_screen.dart';
import 'package:katena_dashboard/screens/topology/topologyview/topology_view_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:yaml/yaml.dart';



import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding and decoding

Provider ServiceProvider = Provider.instance;
Widget simpleTopology = Container();


class DeployBody extends StatefulWidget {
  const DeployBody({super.key});

  @override
  _DeployState createState() => _DeployState();
}

class _DeployState extends State<DeployBody> {
  final _formKey = GlobalKey<FormState>();
  String? selectedOption; // Allow null for no selection
  String _dynamicText = "Deploy a new topology..."; // Variabile per il testo dinamico

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
        //final yamlMap = loadYaml(yamlString);
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
    final url = Uri.parse(
        'http://localhost:5001/run-script'); // Cambia l'URL se necessario

    //var contentFileJson = jsonEncode(contentFile);


    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'container_id': '12cfd61cb30f', // Sostituisci con l'ID del contenitore
        'script_command': '/bin/sh -c ./run-deploy.sh',
        'content_yaml': contentFile,
      }),
    );

    if (response.statusCode == 200) {
      // Se il server restituisce una risposta OK, mostra l'output
      final String output = response.body;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Output: $output')));
      _updateText(output);
    } else {
      // Se il server non restituisce una risposta OK, mostra un errore
      final String error = response.body;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
      print(error);
    }
  }

  Future<void> _withdrawRequest() async {
    final url = Uri.parse(
        'http://localhost:5001/withdraw'); // Cambia l'URL se necessario

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'container_id': '12cfd61cb30f', // Sostituisci con l'ID del contenitore
      }),
    );

    if (response.statusCode == 200) {
      // Se il server restituisce una risposta OK, mostra l'output
      final String output = response.body;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Output: $output')));
      _updateText("Deploy a new topology...");
    } else {
      // Se il server non restituisce una risposta OK, mostra un errore
      final String error = response.body;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
      print(error);
    }
  }

  void _handleRadioValueChange(String? value) {
    setState(() {
      // Toggle selection
      if (selectedOption == value) {
        selectedOption = null; // Deselect if already selected
      } else {
        selectedOption = value; // Select new option
      }
    });
    print('Selected option: $selectedOption'); // Example action
  }

  void _updateText(String result) {
    setState(() {
      _dynamicText = result;
    });
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

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
                    /*
                    simpleTopology = await ServiceProvider.CreateNode();
                    setState(() {
                      simpleTopology;
                    });
                     */
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
                margin: const EdgeInsets.all(8.0), // Aumentato il margine esterno per maggiore distanziamento
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2), // Bordo nero
                  borderRadius: BorderRadius.circular(5), // Arrotondamento angoli più evidente
                ),
                child: Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'File selection',
                        style: TextStyle(
                          fontSize: 16, // Dimensione testo leggermente più grande
                          fontWeight: FontWeight.bold, // Grassetto per evidenziare il titolo
                          color: Colors.black87,
                          letterSpacing: 1.0, // Spaziatura delle lettere per eleganza
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Margine interno sui lati e sopra/sotto
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: _controllPickFile,
                            child: Text('Pick File...'),
                          ),
                          SizedBox(width: 20), // Spazio tra il pulsante e il nome del file
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight, // Allinea il testo a destra
                              child: Text(
                                _fileName ?? 'No file selected',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1, // Limita il testo a una sola linea
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
      Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _dynamicText,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
