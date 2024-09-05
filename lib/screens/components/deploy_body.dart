import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/topology/topologymanangement/topology_management_screen.dart';
import 'package:katena_dashboard/screens/topology/topologyview/topology_view_screen.dart';

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

  Future<void> _sendRequest() async {
    final url = Uri.parse('http://localhost:5001/run-script'); // Cambia l'URL se necessario

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'container_id': '12cfd61cb30f', // Sostituisci con l'ID del contenitore
        'script_command': '/bin/sh -c ./run-deploy.sh' ,
      }),
    );

    if (response.statusCode == 200) {
      // Se il server restituisce una risposta OK, mostra l'output
      final String output = response.body;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Output: $output')));
      print(output);
    } else {
      // Se il server non restituisce una risposta OK, mostra un errore
      final String error = response.body;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedOption = 'Option 1';
    Size size = MediaQuery.of(context).size; // with this query I get (w,h) of the screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deploy Viewer'),
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
                    simpleTopology= await ServiceProvider.CreateNode();
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
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                      return TopologyManagementScreen();
                    }), (route) => false);
                  },
                ),
                PopupMenuItem<String>(
                  value: '3',
                  child: Text('View a Topology'),
                  onTap: () async {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
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
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Center(
                    child: simpleTopology,
                  ),
                ],
              ),
              SizedBox(height: 20), // Add some space between widgets
              ElevatedButton(
                onPressed: _sendRequest,
                child: Text('Run Script'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
