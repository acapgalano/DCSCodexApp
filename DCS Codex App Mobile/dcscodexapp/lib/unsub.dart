import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dcscodexapp/group.dart';
import 'package:http/http.dart' as http;
import 'package:dcscodexapp/sublist.dart';
import 'package:flutter/scheduler.dart';

class RemoveSubscriptionRoute extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return RemoveSubscriptionRouteState();
  }
}

class RemoveSubscriptionRouteState extends State<RemoveSubscriptionRoute>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
      ),
      body: Text("Hello"),
    );
  }
}