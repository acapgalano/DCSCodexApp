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
Anica Galano | 2/9/2020 - CurrentSubscriptionPost, AddSubscriptionRoute, AddSubscriptionRouteState
Anica Galano | 2/12/2020 - Fixed state update delay (added 'await' to _)
Anica Galano | 2/13/2020 - Fixed UI elements, added Toast for no group selected when adding

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
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

/*
Group (Class)
--------------
Serves as an object following the model of a Group. Used to keep track of
newly subscribed Groups.
 */
class Group {
  final String name;

  Group({this.name});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name'],
    );
  }
}

/*
CurrentSubscriptionPost (Class)
-------------------------------
Serves as an object following the model of a User. The object is used to
retrieve data from the server when requesting for the current subscription
list of the user. To be used to create a new object with updated subscription list.
 */

class CurrentSubscriptionPost {
  final int id;
  final String email;
  final List groups;

  CurrentSubscriptionPost({this.id, this.email, this.groups});

  factory CurrentSubscriptionPost.fromJson(Map<String, dynamic> json) {
    return CurrentSubscriptionPost(
      id: json['id'],
      email: json['email'],
      groups: json['groups'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'groups': groups.map((value) => ({"name": value})).toList(),
      };
}

/*
AddSubscriptionRoute (Class, extends StatefulWidget)
-------------------------------------------------------
Represents the Add Subscription Activity or Screen. Used to create states.
 */

class AddSubscriptionRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddSubscriptionRouteState();
  }
}

/*
AddSubscriptionRoute (Class, extends StatefulWidget)
-------------------------------------------------------
Used for state management of the Add Subscription Route.
 */

class AddSubscriptionRouteState extends State<AddSubscriptionRoute> {
  Future<CurrentSubscriptionPost> subscriptions;
  List<Group> groups;
  List<bool> _values;

  Future<CurrentSubscriptionPost> fetchSubscriptions() async {
    var response;
    try {
      //make GET request for Subscription list, await til timeout
      response = await http
          .get('http://10.0.2.2:8000/update/2')
          .timeout(const Duration(seconds: 5));
    } on TimeoutException catch (_) {
      print("Timeout from GET request.");
      Fluttertoast.showToast(msg: "Error: Failed to reached server.");
    } on SocketException catch (_) {
      print("SocketException while putting.");
      Fluttertoast.showToast(msg: "Error: Failed to connect to server.");
    }

    if (response.statusCode == 200) {
      print("Add Sub, Get SubList: Success!");
      return CurrentSubscriptionPost.fromJson(json.decode(response.body));
    }
    return null;
  }

  List<Group> parseGroups(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Group>((json) => Group.fromJson(json)).toList();
  }

  // Process GET request for list of all Groups in DCS Codex
  Future<List<Group>> fetchGroups() async {
    var response;
    if (groups == null) {
      try {
        print("Will await GET request.");
        //make GET request for Subscription list, await til timeout
        response = await http
            .get('http://10.0.2.2:8000/addgroup')
            .timeout(const Duration(seconds: 5));

      } on TimeoutException catch (_) {
        print("Timeout from GET request.");
        Fluttertoast.showToast(msg: "Error: Failed to connect to server.");

      } on SocketException catch (_) {
        print("SocketException from GET request.");
        Fluttertoast.showToast(msg: "Error: Failed to reach server.");
      }
      if (response.statusCode == 200) {
        print("Add Sub, Get GroupList: Success!");
        var responseJson = json.decode(response.body);
        groups = (responseJson as List).map((p) => Group.fromJson(p)).toList();
        _values = groups.map((a) => false).toList();
        return groups;
      }
    } else {
      return groups;
    }
    return null;
  }

  // Process PUT request to update User's subscriptions
  _makePutRequest(String json) async {
    // set up PUT request arguments
    String url = 'http://10.0.2.2:8000/update/2';
    Map<String, String> headers = {"Content-type": "application/json"};

    // make PUT request
    final response = await http.put(url, headers: headers, body: json);

    // check the status code for the result
    int statusCode = response.statusCode;

    // this API passes back the updated item with the id added
    setState(() {
      print(response.body);
    });

    if (statusCode == 200) {
      Fluttertoast.showToast(msg: "Successfully added subscriptions.");
    }
  }

  // Process current subscriptions, add new subscriptions, update User's subscriptions
  _addSubscriptions() async {
    var subscriptions = await fetchSubscriptions();
    var temp = [];
    // Add current subscriptions to temporary list
    for (var i = 0; i < subscriptions.groups.length; i++) {
      temp.add(subscriptions.groups[i]['name']);
    }
    //Add new subscriptions to temporary list
    for (var i = 0; i < _values.length; i++) {
      if (_values[i] == true) {
        temp.add(groups[i].name);
      }
    }
    //Build the json file to send in PUT request
    String json = jsonEncode(CurrentSubscriptionPost(
        id: 2, email: 'testuser@test.com', groups: temp));
    print(json);
    //Send updated user content to server through OUT request
    await _makePutRequest(json);
  }
  // Widget that builds the list content of the available groups to subscribe to
  Widget _buildRow(List _groups) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _groups.length,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(_groups[index].name),
          value: _values[index],
          onChanged: (bool value) {
            setState(() {
              _values[index] = value;
              print("$index = $value || $_values");
            });
          },
        );
      },
    );
  }

  // Main Widget for the Add Subscription Route
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add a Subscription"),
          backgroundColor: Colors.red[900],
        ),
        body: Column(children: [
          FutureBuilder(
            future: fetchGroups(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildRow(snapshot.data);
              }
              return Scaffold();
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            // Button that adds subscriptions
            child: RaisedButton(
              splashColor: Colors.red[700],
              onPressed: () async {
                if(!_values.contains(true)){ //If no group selected, alert User
                  Fluttertoast.showToast(msg: "No group selected.");
                }else {
                  await _addSubscriptions();
                  // Return to Subscription List Route
                  Navigator.of(context).pop(() {
                    setState(() {});
                  });
                }
              },
              child: const Text('Add Subscriptions',
                  style: TextStyle(fontSize: 20)),
              color: Colors.red[900],
              textColor: Colors.white,
              elevation: 5,
            ),
          )
        ]));
  }
}
