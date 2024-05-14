import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/dashboard_body.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: DashboardBody());
    throw UnimplementedError();
  }
}