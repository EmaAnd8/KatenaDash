import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/topology/topologymanangement/topology_management_screen.dart';
import 'package:katena_dashboard/screens/topology/topologyview/topology_view_screen.dart';


Provider ServiceProvider = Provider.instance;
Widget simpleTopology=Container();
class DeployBody extends StatefulWidget{
  const DeployBody({super.key});

  @override
  _DeployState createState() =>  _DeployState();



}

class  _DeployState extends State<DeployBody > {
  final _formKey = GlobalKey<FormState>();



















  @override
  Widget build(BuildContext context) {
    // _loadAndConvertYaml2();
    String selectedOption = 'Option 1';
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Scaffold(

      appBar: AppBar(
        title: const Text('Deploy Viewer'),
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context){return HomeScreen() ;},),);

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
                  onTap: (){
                    //Navigator.push(context, MaterialPageRoute(builder: (context){return TopologyManagementScreen() ;},),);

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
                  }
                ),

              ];
            },
            icon: Icon(Icons.menu), //

          ),
        ],

      ),




      body:Container(
        width: size.width,
        height: size.height,
        color: Colors.white,
      child:SingleChildScrollView(

        child:Column(

            children: <Widget>[

              Stack(
                alignment: Alignment.center,

                children: <Widget>
                [
                  /*
                  Row(
                    children: simpleTopology

                  ),

                   */
                  Center(
                    child: simpleTopology,
                  ),

                ],

              )


            ]
        ),
      ),
      ),
    );
  }

}