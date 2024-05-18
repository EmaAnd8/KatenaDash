


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:katena_dashboard/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../firebase_options.dart';
import '../settings/settings_screen.dart';
import '../services/services_provider.dart';
import 'dart:io';


final storageRef = FirebaseStorage.instance.ref();
class  DashboardBody extends StatefulWidget{
  const DashboardBody({super.key});

  @override
  _DashboardState createState() => _DashboardState();


}

class _DashboardState extends State<DashboardBody> {




  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size; //with this query I get (w,h) of the screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('KatenaDashboard'),
        backgroundColor: CupertinoColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            color: Colors.black,
            onPressed: () async {
              //upload image
              WidgetsFlutterBinding.ensureInitialized();
              await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              );
              final imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              //SharedPreferences prefs = await SharedPreferences.getInstance();
              if(imageFile!=null) {
                final profileImagePath = 'profile_images/${FirebaseAuth.instance
                    .currentUser?.uid}/profile_picture.jpg';
                final uploadTask = storageRef.child(profileImagePath).putFile(
                    File(imageFile.path));
                final downloadUrl = await (await uploadTask).ref
                    .getDownloadURL();
                await FirebaseAuth.instance.currentUser?.updateProfile(
                    photoURL: downloadUrl);
              }else{
                  print("wrong path");
              }
              },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){return SettingsScreen();},),);
            },
          ),
          IconButton(
            icon: const Icon(Icons.login),
            color: Colors.black,
            onPressed: () async {
              WidgetsFlutterBinding.ensureInitialized();
              await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              );
               Provider serviceProvider=Provider.instance;
               serviceProvider.Signout();
               Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return LoginScreen();},),);

            },
          ),

        ],
      ),
      body: Container(
        //initialize the chart
         child: Container(
             width: size.width/3,
             child: SfCartesianChart(
                  // Initialize category axis
                  primaryXAxis: CategoryAxis(),
              series: <CartesianSeries>[
              // Initialize line series
              LineSeries<ChartData, String>(
              dataSource: [
              // Bind data source
                  ChartData('Jan', 35),
                  ChartData('Feb', 28),
                  ChartData('Mar', 34),
                  ChartData('Apr', 32),
                  ChartData('May', 40)
              ],
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y
                  )
                  ]
              )
        )
      )
        );

  }
}



class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double? y;
}
