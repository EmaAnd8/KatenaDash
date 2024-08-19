import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/screens/components/topology_management_body.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/deploy/deploy_screen.dart';
import 'package:katena_dashboard/screens/topology/topologymanangement/topology_management_screen.dart';
import 'package:yaml/yaml.dart';

Provider serviceProvider = Provider.instance;
Graph graph = Graph()..isTree = false;
Map<String, String> nodeDescriptions = {};

class TopologyViewBody extends StatefulWidget {
  const TopologyViewBody({super.key});

  @override
  _TopologyViewState createState() => _TopologyViewState();
}

class _TopologyViewState extends State<TopologyViewBody> {
  bool _isDrawerOpen = false;
  Node? rootnode;

  @override
  void initState() {
    super.initState();
    initializeGraph();
    _loadNodeDescriptions();
  }

  void initializeGraph() {
    graph = Graph()..isTree = false;
    rootnode = Node.Id('Root Node');
    graph.addNode(rootnode!);


  }

  Future<void> _loadNodeDescriptions() async {
    try {
      List<String> keyTypes = await serviceProvider.NodesDefinition() as List<String>;
      for (var type in keyTypes) {
        var yamlDescription = await serviceProvider.GetDescriptionByType(type);
        YamlMap? descriptionMap = yamlDescription;
        if (descriptionMap != null) {
          nodeDescriptions[type] = _formatYamlMap(descriptionMap, 0);
        }
      }
      setState(() {});
    } catch (e) {
      print('Error loading node descriptions: $e');
    }
  }

  String _formatYamlMap(YamlMap map, int indentLevel) {
    final buffer = StringBuffer();
    map.forEach((key, value) {
      buffer.write('${' ' * indentLevel * 2}$key:');
      if (value is YamlMap) {
        buffer.write('\n');
        buffer.write(_formatYamlMap(value, indentLevel + 1));
      } else {
        buffer.write(' $value\n');
      }
    });
    return buffer.toString();
  }

  Widget fetchNodeIcon(String type) {
    if (type.contains("network")) {
      return Image.asset('assets/icons/worldwide_10969702.png', width: 24, height: 24);
    } else if (type.contains("wallet")) {
      return Image.asset('assets/icons/wallet_4121117.png', width: 24, height: 24);
    } else if (type.contains('contract')) {
      return Image.asset('assets/icons/smart_14210186.png', width: 24, height: 24);
    }
    return Image.asset('assets/icons/icons8-topology-53.png', width: 24, height: 24);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    SugiyamaConfiguration builder = SugiyamaConfiguration()
      ..nodeSeparation = 50
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topology Viewer'),
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return HomeScreen();
            }));
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String item) {
              setState(() {
                // Handle selected options here
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: '1',
                  child: const Text('Make the Deploy'),
                  onTap: () async {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                      return DeployScreen();
                    }), (route) => false);
                  },
                ),
                PopupMenuItem<String>(
                  value: '2',
                  child: const Text('Edit your Topology'),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                      return TopologyManagementScreen();
                    }), (route) => false);
                  },
                ),
                PopupMenuItem<String>(
                  value: '3',
                  child: const Text('Insert a Topology'),
                  onTap: () async {
                    await _loadAndConvertYaml();
                  },
                ),
              ];
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  alignment: Alignment.topLeft,
                ),
                Expanded(
                  child: InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(100),
                    minScale: 0.01,
                    maxScale: 5.6,
                    panEnabled: true, // Enable panning
                    scaleEnabled: true, // Enable scaling
                    child: GraphView(
                      graph: graph,
                      algorithm: SugiyamaAlgorithm(builder),
                      paint: Paint()
                        ..strokeWidth = 1
                        ..style = PaintingStyle.fill,
                      builder: (Node node) {
                        var nodeData = node.key?.value as String?;
                        return nodeData != null ? nodeWidget(node, nodeData) : Container();
                      },
                    ),
                  ),
                ),
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _isDrawerOpen ? 0 : -250,
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
                          'Topology manager',
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
                            const Divider(),
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
    );
  }

  Widget nodeWidget(Node node, String nodeData) {
    List<String> parts = nodeData.split('\n');
    String nodeName = parts.length > 1 ? parts[0].replaceFirst('name:', '') : '';
    String type = parts.length > 1 ? parts[1].replaceFirst('type:', '') : '';

    // Check if the node is self-referential based on the provided TOSCA data
    bool isSelfReferential = nodeName == 'testMakerOracle'; // Adjust this condition as needed

    return Tooltip(
      message: nodeDescriptions[type] ?? 'No description available',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              fetchNodeIcon(type),
              const SizedBox(height: 4),
              Text('name: $nodeName'),
              Text('type: $type'),
            ],
          ),
          if (isSelfReferential)
            Positioned(
              right: 0,
              top: 0,
              child: Transform.rotate(
                angle: 0.5, // Adjust the angle for the loop
                child: Icon(Icons.loop, size: 16, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadAndConvertYaml() async {
    setState(() {
      graph = Graph()..isTree = false;
      rootnode = Node.Id('Root Node');
      graph.addNode(rootnode!);
    });

    final newGraph = await serviceProvider.TopologyGraphFromYaml();

    setState(() {
      if (newGraph != null) {
        graph = newGraph;


      }
    });
  }

  Future<void> _loadNodeDefinitions() async {
    setState(() {
      sidebarItems = [];
    });

    try {
      List<String> keyTypes = await ServiceProvider.TopologyExamples() as List<String>;

      for (var key in keyTypes) {
        String diff_key = key.replaceFirst(".yaml", "");
        sidebarItems.add({
          'title': "Add ${diff_key} topology",
          'onTap': () async {
            setState(() async {
              graph = await ServiceProvider.TopologyGraphFromYamlGivenName2(key) as Graph;
            });
          },
        });
      }

      String key_ens = "Add ens topology";
      sidebarItems.add({
        'title': key_ens,
        'onTap': () async {
          final generated_graph = await ServiceProvider.TopologyGraphFromYamlGivenName("ens.yaml") as Graph;
          setState(() {
            graph = generated_graph;
          });
        },
      });

      String key_dxdy = "Add dxdy topology";
      sidebarItems.add({
        'title': key_dxdy,
        'onTap': () async {
          final generated_graph = await ServiceProvider.TopologyGraphFromYamlGivenName("dydx.yaml") as Graph;
          setState(() {
            graph = generated_graph;
          });
        },
      });

      String key_darkforest = "Add dark forest topology";
      sidebarItems.add({
        'title': key_darkforest,
        'onTap': () async {
          final generated_graph = await ServiceProvider.TopologyGraphFromYamlGivenName("dark-forest.yaml") as Graph;
          setState(() {
            graph = generated_graph;
          });
        },
      });

      setState(() {});
    } catch (e) {
      print('Error loading node definitions: $e');
    }
  }
}
