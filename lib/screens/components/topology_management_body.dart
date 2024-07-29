import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/constants.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/deploy/deploy_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/topology/topologyview/topology_view_screen.dart';

Provider ServiceProvider = Provider.instance;

List<Map<String, dynamic>> sidebarItems = [];
Graph graph = Graph()..isTree = false;
final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
Node? rootNode;
class TopologyManagementBody extends StatefulWidget {
  const TopologyManagementBody({super.key});

  @override
  _TopologyManagementState createState() => _TopologyManagementState();
}

class _TopologyManagementState extends State<TopologyManagementBody> {
  final _formKey = GlobalKey<FormState>();
  bool _isDrawerOpen = false;



  @override
  void initState() {
    super.initState();
    // Initialize the graph with a default node
    rootNode = Node.Id('Root Node');
    graph.addNode(rootNode!);
  }

  Widget fetchNodeIcon(String nodeId) {
    if (nodeId.contains("network")) {
      return Image.asset('assets/icons/worldwide_10969702.png', width: 24, height: 24);
    } else if (nodeId.contains("wallet")) {
      return Image.asset('assets/icons/wallet_4121117.png', width: 24, height: 24);
    } else if (nodeId.contains('contract')) {
      return Image.asset('assets/icons/smart_14210186.png', width: 24, height: 24);
    }
    return Image.asset('assets/icons/icons8-topology-53.png', width: 24, height: 24);
  }

  Future<void> _loadNodeDefinitions() async {
    setState(() {
      sidebarItems = [];
    });

    try {
      List<String> keyTypes = await ServiceProvider.NodesDefinition() as List<String>;

      for (var key in keyTypes) {
        print(key);
        sidebarItems.add({
          'title': key,
          'onTap': () {
            setState(() {
              graph = ServiceProvider.TopologyCreator(key, graph,rootNode) as Graph;
              print('$key tapped');
            });
          },
        });
      }

      setState(() {});
    } catch (e) {
      print('Error loading node definitions: $e');
    }
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
                    Container(
                      height: size.height,
                      width: size.width - 250, // Adjust the width based on drawer
                      child: InteractiveViewer(
                        constrained: false,
                        boundaryMargin: EdgeInsets.all(100),
                        minScale: 0.01,
                        maxScale: 5.6,
                        child: GraphView(
                          graph: graph,
                          algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                          builder: (Node node) {
                            var nodeId = node.key?.value as String?;
                            return nodeId != null ? nodeWidget(nodeId) : Container();
                          },
                        ),
                      ),
                    ),
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

  Widget nodeWidget(String nodeId) {
    return GestureDetector(
      onTap: () {
        print('Node $nodeId tapped');
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          fetchNodeIcon(nodeId),
          SizedBox(width: 8),
          Text(nodeId),
        ],
      ),
    );
  }
}
