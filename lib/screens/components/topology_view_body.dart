import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';
import 'package:katena_dashboard/screens/services/services_provider.dart';
import 'package:katena_dashboard/screens/topology/topologymanangement/topology_management_screen.dart';


Provider ServiceProvider = Provider.instance;
List<Widget> simpleTopology=[];
class TopologyViewBody extends StatefulWidget{
  const TopologyViewBody({super.key});

  @override
  _TopologyViewState createState() =>  _TopologyViewState();



}

class  _TopologyViewState extends State<TopologyViewBody > {
  final _formKey = GlobalKey<FormState>();



  String ToscatoJSON="";



  Future<void> _loadAndConvertYaml() async {


    //String result = await serviceProvider.Parser('assets/input/simple-relationship-with-args.yaml');
    simpleTopology=(await ServiceProvider.TopologyPrinterFromYaml())!;
    setState(() {
      simpleTopology;
    });
  }


  Future<void> _loadAndConvertYaml2() async {


    //String result = await serviceProvider.Parser('assets/input/simple-relationship-with-args.yaml');
    simpleTopology=(await ServiceProvider.TopologyPrinter())!;
    setState(() {
      simpleTopology;
    });
  }



  @override
  Widget build(BuildContext context) {
   // _loadAndConvertYaml2();
    String selectedOption = 'Option 1';
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Scaffold(

      appBar: AppBar(
        title: const Text('Topology Viewer'),
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
                    Navigator.push(context, MaterialPageRoute(builder: (context){return TopologyManagementScreen() ;},),);
                  },

                ),
                PopupMenuItem<String>(
                  value: '3',
                  child: Text('Insert a Topology'),

                    onTap: () async {
                      /*
                    simpleTopology= await ServiceProvider.CreateNode();
                    setState(() {
                      simpleTopology;
                    });

                     */
                      //ServiceProvider.TopologyPrinterFromYaml();
                       await _loadAndConvertYaml();
                    },

                ),

              ];
            },
            icon: Icon(Icons.menu), //

          ),
        ],

      ),




      body: SingleChildScrollView(
        child:Column(

            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 16.0),
                alignment:Alignment.topLeft,

                child:const Text("Here you can view your Topology! ",
                  style: TextStyle(color: Colors.black,fontSize: 30),
                  textAlign:TextAlign.left,),
              ),
              Stack(
                alignment: Alignment.center,

                children: <Widget>
                [
                  Row(
                    children: simpleTopology
                  ),
                ],

              )


            ]
        ),
      ),

    );
  }
}