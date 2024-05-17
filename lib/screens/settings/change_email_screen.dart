import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:katena_dashboard/screens/components/change_name_body.dart';

import '../components/change_email_body.dart';
import '../components/dashboard_body.dart';
import '../components/forgot_password_body.dart';


class ChangeEmailScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: ChangeEmailBody());
    throw UnimplementedError();
  }
}