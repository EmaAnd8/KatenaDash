import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:katena_dashboard/screens/components/deploy_body.dart';
import 'package:katena_dashboard/screens/components/graphiccomponents/simple_node.dart';
// ... (Your other imports)

class SimpleGraph extends StatelessWidget {
  const SimpleGraph({super.key});

  Future<Graph?> _getGraph() async {
    Graph? graph = Graph()..isTree = false;
    graph = await ServiceProvider.TopologyGraphFromYaml();
    return graph;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Graph?>(
      future: _getGraph(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.nodes.isEmpty) {
          return Center(child: Text("Error loading graph: ${snapshot.error ?? 'No data'}"));
        } else {
          return InteractiveViewer( // Allow zooming and panning for large graphs
            //constrained: false,
            child: GraphView(
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
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CustomPaint(
                          painter: BlueNodePainter(),
                          size: const Size(18, 18),
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
              },
            ),
          );
        }
      },
    );
  }
}