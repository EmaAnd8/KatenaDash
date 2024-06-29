import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:katena_dashboard/screens/dashboard/dashboard_screen.dart';



class TopologyManagementBody extends StatefulWidget{
  const TopologyManagementBody({super.key});

  @override
  _TopologyManagementState createState() =>  _TopologyManagementState();


}

class  _TopologyManagementState extends State<TopologyManagementBody > {
  final _formKey = GlobalKey<FormState>();








  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Scaffold(

      appBar: AppBar(
        title: const Text('Topology Editor'),
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context){return HomeScreen() ;},),);

          },
        ),
      ),

      drawer:  Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
        DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Text(
          'Sidebar Header',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),

      ),

      body: SingleChildScrollView(
        child:Column(

            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 16.0),
                alignment:Alignment.topLeft,

                child:const Text("Here you can manage your Topology ",
                  style: TextStyle(color: Colors.black,fontSize: 30),
                  textAlign:TextAlign.left,),
                ),



            ]
        ),
      ),

    );
  }
}