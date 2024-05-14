import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/dashboard_body.dart';
import '../components/forgot_password_body.dart';


class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: ResetPasswordBody());
    throw UnimplementedError();
  }
}