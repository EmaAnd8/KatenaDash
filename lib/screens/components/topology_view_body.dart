import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/components/graphiccomponents/simple_graph.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/deploy/deploy_screen.dart';
import 'package:katena_dashboard/screens/topology/topologymanangement/topology_management_screen.dart';

Provider serviceProvider = Provider.instance;
Widget simpleTopology = Container();

class TopologyViewBody extends StatefulWidget {
  const TopologyViewBody({super.key});

  @override
  _TopologyViewState createState() => _TopologyViewState();
}

class _TopologyViewState extends State<TopologyViewBody> {
  final _formKey = GlobalKey<FormState>();
  String selectedOption = 'Option 1';

  Future<void> _loadAndConvertYaml() async {
    setState(() {
      simpleTopology = Container();
    });
    // Rebuild the widget to ensure it re-initializes
    simpleTopology = SimpleGraph(key: UniqueKey());
    setState(() {
      simpleTopology;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topology Viewer'),
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            selectedOption="";
              return HomeScreen();
            }));
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return DeployScreen();
                    }));
                  },
                ),
                PopupMenuItem<String>(
                  value: '2',
                  child: Text('Edit your Topology'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return TopologyManagementScreen();
                    }));
                  },
                ),
                PopupMenuItem<String>(
                  value: '3',
                  child: Text('Insert a Topology'),
                  onTap: () async {
                    await _loadAndConvertYaml();
                  },
                ),
              ];
            },
            icon: Icon(Icons.menu),
          ),
        ],
      ),
      body: Container(
      color: Colors.white,
      width: size.width,
      height: size.height,
      child:SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: size.height,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Center(
                    child: simpleTopology,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
