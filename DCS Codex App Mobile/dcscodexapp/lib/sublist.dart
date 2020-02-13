import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dcscodexapp/addsub.dart';
import 'package:dcscodexapp/group.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class SubscriptionPost {
  final int id;
  final String email;
  final List groups;

  SubscriptionPost({this.id, this.email, this.groups});

  factory SubscriptionPost.fromJson(Map<String, dynamic> json) {
    return SubscriptionPost(
      id: json['id'],
      email: json['email'],
      groups: json['groups'],
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'email': email,
        'groups': groups,
      };
}

class SubscriptionListRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SubscriptionListRouteState();
  }
}

class SubscriptionListRouteState extends State<SubscriptionListRoute> {
  List groups;
  Future<SubscriptionPost> post;

  Future<SubscriptionPost> fetchSubscriptions() async {
    var response;
    try {
      print("Will await.");
      response = await http.get('http://10.0.2.2:8000/update/2').timeout(const Duration(seconds: 2));
    } on TimeoutException catch (_){
      print("Timeout.");
      Fluttertoast.showToast(msg: "Failed to connect to server.");
    } on SocketException catch(_){
      print("SocketException while putting.");
      Fluttertoast.showToast(msg: "Error: Failed to reach server.");
    }
    if (response.statusCode == 200) {
      print("Success!");
      return SubscriptionPost.fromJson(json.decode(response.body));
    }
  }

  _makePutRequest(String json) async {
    var response;
    // set up PUT request arguments
    String url = 'http://10.0.2.2:8000/update/2';
    Map<String, String> headers = {"Content-type": "application/json"};

    // make PUT request
    try {
      print("Will await.");
      response = await http.put(url, headers: headers, body: json).timeout(const Duration(seconds: 2));
    } on TimeoutException catch (_){
      print("Timeout while putting.");
      Fluttertoast.showToast(msg: "Error: Failed to reach server.");
    } on SocketException catch(_) {
      print("SocketException while putting.");
      Fluttertoast.showToast(msg: "Error: Failed to reach server.");
    }
    // check the status code for the result
    int statusCode = response.statusCode;

    // this API passes back the updated item with the id added
    setState(() {
      print(response.body);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subscription List'), actions: <Widget>[
        IconButton(icon: Icon(Icons.list), onPressed: () => print("yay"))
      ]),
      body: FutureBuilder(
        future: fetchSubscriptions(),
        builder:
            (BuildContext context, AsyncSnapshot<SubscriptionPost> snapshot) {
          if (snapshot.hasData) {
            return _buildRow(snapshot.data.groups);
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.playlist_add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSubscriptionRoute()),
          );
        },
      ),
    );
  }

  _confirmResult(bool isYes, BuildContext context) {}

  Widget _buildRow(List _groups) {
    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(_groups[index]['name']),
            trailing: IconButton(
              icon: Icon(Icons.cancel, color: Colors.redAccent),
              tooltip: 'Unsubscribe from group',
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text("Unsubscribe from Group"),
                          content: Text(
                              "Are you sure you want to unsubscribe from this group?"),
                          actions: [
                            FlatButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(context);
                              },
                            ),
                            FlatButton(
                              child: Text('Confirm'),
                              onPressed: () {
                                _groups.removeAt(index);
                                String json = jsonEncode(SubscriptionPost(id: 2, email: 'testuser@test.com', groups: _groups));
                                _makePutRequest(json);
                                Navigator.of(context).pop();
                              },
                            )
                          ]);
                    });
              },
            ));
      },
    );
  }
}
