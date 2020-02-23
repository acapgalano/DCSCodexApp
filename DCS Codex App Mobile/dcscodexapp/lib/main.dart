/*
“This is a course requirement for CS 192 Software Engineering II under the supervision of
Asst. Prof. Ma. Rowena C. Solamo of the Department of Computer Science, College of Engineering,
University of the Philippines, Diliman for the AY 2019-2020”.

Authors:
-------------
* Anica Galano

================================================================
Code History:
-------------
Anica Galano | 2/9/2020 - main function, DCSCodexApp widget

=================================================================
File Creation Date: February 9, 2020
Development Group: CS 192 WF-10v2 Group 5
Client Group: Asst. Prof. Ma. Rowena C. Solamo
Purpose of Software: The DCS Codex Notification System aims to add the elements of notifications
and groups to the existing DCS Codex System through a mobile app.
*/

import 'package:flutter/material.dart';
import 'sublist.dart';


void main() {
  runApp(DCSCodexApp());
}

class DCSCodexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DCS Codex',
      home: SubscriptionListRoute(),
    );
  }
}