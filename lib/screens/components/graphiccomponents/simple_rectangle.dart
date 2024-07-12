
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget rectangleWidget() {
  return InkWell(
    onTap: () {
      print('clicked');
    },
    child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(color: Colors.blue, spreadRadius: 1),
          ],
        ),
        //child: Text('Node ${a}')
  ),
  );
}