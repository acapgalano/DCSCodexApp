/*
License:
------------
This is a course requirement for CS 192 Software Engineering II under the supervision of
Asst. Prof. Ma. Rowena C. Solamo of the Department of Computer Science, College of Engineering,
University of the Philippines, Diliman for the AY 2019-2020.

================================================================
Authors:
-------------
* Anica Galano

================================================================
Code History:
-------------
Anica Galano | 2/9/2020 - SubscriptionPost, SubscriptionListRoute, SubscriptionListRouteState
Anica Galano | 2/12/2020 - Additional exception handling for timeout and socket errors
Anica Galano | 2/13/2020 - Fixed UI elements, added Toast for successful User updates

=================================================================
File Creation Date: February 9, 2020
Development Group: CS 192 WF-10v2 Group 5
Client Group: Asst. Prof. Ma. Rowena C. Solamo
Purpose of Software: The DCS Codex Notification System aims to add the elements of notifications
and groups to the existing DCS Codex System through a mobile app.

*/

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dcscodexapp/addsub.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

/*
SubscriptionPost (Class)
--------------------------
Serves as an object following the model of a user. The object is used to
retrieve data from the server when requesting for the current subscription
list of the user.
 */

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'groups': groups,
      };
}

/*
SubscriptionListRoute (Class, extends StatefulWidget)
--------------------------------------------------------
Represents the Subscription List Activity or Screen. Used to create states.
 */

class SubscriptionListRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SubscriptionListRouteState();
  }
}

/*
SubscriptionListRouteState (Class, extends State<SubscriptionListRoute>)
----------------------------------------------------------------------------
Used for state management of the Subscription List Route.
 */

class SubscriptionListRouteState extends State<SubscriptionListRoute> {
  List groups; // contains the Groups to be displayed in Subscription List

  // Process GET request for Subscriptions of User.
  Future<SubscriptionPost> fetchSubscriptions() async {
    var response; // to contain response from the server
    try {
      print("Will await GET request.");
      //make GET request for Subscription list, await til timeout
      response = await http
          .get('http://10.0.2.2:8000/update/2')
          .timeout(const Duration(seconds: 10));
    } on TimeoutException catch (_) {
      print("Timeout from GET request.");
      Fluttertoast.showToast(msg: "Error: Failed to reached server.");
    } on SocketException catch (_) {
      print("SocketException while putting.");
      Fluttertoast.showToast(msg: "Error: Failed to connect to server.");
    }
    if (response.statusCode == 200) {
      print("Success, subscription list received!");
      return SubscriptionPost.fromJson(json.decode(response.body));
    }
    return null;
  }

  // Process PUT request to update User's subscriptions
  _makePutRequest(String json) async {
    var response;
    // set up PUT request arguments
    String url = 'http://10.0.2.2:8000/update/2';
    Map<String, String> headers = {"Content-type": "application/json"};

    try {
      print("Will await PUT request.");
      // make PUT request
      response = await http
          .put(url, headers: headers, body: json)
          .timeout(const Duration(seconds: 10));
    } on TimeoutException catch (_) {
      print("Timeout while putting.");
      Fluttertoast.showToast(msg: "Error: Failed to reach server.");
    } on SocketException catch (_) {
      print("SocketException while putting.");
      Fluttertoast.showToast(msg: "Error: Failed to reach server.");
    }
    // check the status code for the result
    int statusCode = response.statusCode;

    // refresh state
    setState(() {
      print(response.body);
    });

    if (statusCode == 200) {
      Fluttertoast.showToast(msg: "Successfully updated subscriptions.");
    }
  }

  // Widget that builds the list content of the Subscription List
  Widget _buildRows(List _groups) {
    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
            elevation: 6.0,
            margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                  title: Text(_groups[index]['name']),
                  // Displays the Group's name
                  trailing: IconButton(
                    // Button to unsubscribe from Group
                    icon: Icon(Icons.cancel, color: Colors.grey[600]),
                    tooltip: 'Click to unsubscribe from Group',
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
                                      String json = jsonEncode(SubscriptionPost(
                                          id: 2,
                                          email: 'testuser@test.com',
                                          groups: _groups));
                                      _makePutRequest(json);
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ]);
                          });
                    },
                  )),
            ));
      },
    );
  }

  // Main Widget for the Subscription List Route
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Subscription List'),
          backgroundColor: Colors.red[900],
          actions: <Widget>[
            IconButton(icon: Icon(Icons.list), onPressed: () => print("yay"))
          ]),
      body: FutureBuilder(
        future: fetchSubscriptions(),
        builder:
            (BuildContext context, AsyncSnapshot<SubscriptionPost> snapshot) {
          if (snapshot.hasData) {
            return _buildRows(snapshot.data.groups);
          }
          return Scaffold();
        },
      ),
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        // Button that leads to Add Subscriptions
        backgroundColor: Colors.red[900],
        child: Icon(Icons.playlist_add, color: Colors.white),
        onPressed: () {
          // Move to Add Subscription Route
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSubscriptionRoute()),
          );
        },
      ),
    );
  }
}
