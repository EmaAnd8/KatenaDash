import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/screens/components/graphiccomponents/simple_node.dart';
import 'package:katena_dashboard/screens/components/topology_management_body.dart';

class SimpleGraph extends StatelessWidget {
  const SimpleGraph({super.key});

  Future<Graph?> _getGraph() async {
    Graph? graph = Graph()..isTree = false;
    graph = await ServiceProvider.TopologyGraphFromYaml();
    print(graph);
    return graph;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Graph?>(
      future: _getGraph(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return GraphView(
            algorithm: FruchtermanReingoldAlgorithm(),
            graph: snapshot.data!,
            paint: Paint()
              ..color = Colors.green
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke,
    builder: (Node node) {
    String nodeId = node.key?.value ?? '';
    return SizedBox(
    width: 60,
    height: 60,
    child: Center( // Center the content
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
    CustomPaint(
    painter: BlueNodePainter(),
    size: const Size(20, 20),
    ),
    Text(
    nodeId,
    style: const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    ),
    ),

    ],
    ),

    ),

    );

    });

        } else if (snapshot.hasError) {
          return Text("Error loading graph: ${snapshot.error}");
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}