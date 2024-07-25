import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/deploy/deploy_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/topology/topologyview/topology_view_screen.dart';

Provider ServiceProvider = Provider.instance;

List<Map<String, dynamic>> sidebarItems = [];

class TopologyManagementBody extends StatefulWidget {
  const TopologyManagementBody({super.key});

  @override
  _TopologyManagementState createState() => _TopologyManagementState();
}

class _TopologyManagementState extends State<TopologyManagementBody> {
  final _formKey = GlobalKey<FormState>();
  bool _isDrawerOpen = false;

  Future<void> _loadNodeDefinitions() async {
    setState(() {
      sidebarItems = [];
    });

    List<String> keyTypes = await ServiceProvider.NodesDefinition() as List<String>;

    for (var key in keyTypes) {
      print(key);
      sidebarItems.add({
        'title': key,
        'onTap': () {
          // Define the action when this item is tapped
          print('$key tapped');
        },
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String selectedOption = 'Option 1';
    Size size = MediaQuery.of(context).size; // Get screen dimensions
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topology Editor'),
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
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
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                      return DeployScreen();
                    }));
                  },
                ),
                const PopupMenuItem<String>(
                  value: '2',
                  child: Text('Export your Topology'),
                ),
                PopupMenuItem<String>(
                  value: '3',
                  child: Text('View your Topology'),
                  onTap: () async {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                      return TopologyViewScreen();
                    }));
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
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              _isDrawerOpen = true;
            });
          },
          onExit: (_) {
            setState(() {
              _isDrawerOpen = false;
            });
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      alignment: Alignment.topLeft,
                    ),
                    Row(),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                left: _isDrawerOpen ? 0 : -250, // Width of the drawer
                top: 0,
                bottom: 0,
                child: MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _isDrawerOpen = true;
                      _loadNodeDefinitions();
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isDrawerOpen = false;
                    });
                  },
                  child: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        const DrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Text(
                            'Component Manager',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        ...sidebarItems.map((item) {
                          return Column(
                            children: [
                              ListTile(
                                title: Text(item['title']),
                                onTap: item['onTap'],
                              ),
                              Divider(),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
