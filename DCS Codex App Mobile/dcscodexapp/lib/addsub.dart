import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dcscodexapp/group.dart';
import 'package:http/http.dart' as http;
import 'package:dcscodexapp/sublist.dart';
import 'package:flutter/scheduler.dart';
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
        'groups': groups.map((value) => ({"name": value})).toList(),
      };
}


class Group {
  final String name;

  //final String type; TODO Add group type distinction (server side too)

  Group({this.name});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      name: json['name'],
    );
  }
}

class AddSubscriptionRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddSubscriptionRouteState();
  }
}

class AddSubscriptionRouteState extends State<AddSubscriptionRoute> {
  Future<SubscriptionPost> subscriptions;
  List<Group> groups;
  List<bool> _values;
  bool updateGroup = false;

  Future<SubscriptionPost> fetchSubscriptions() async {
    final response = await http.get('http://10.0.2.2:8000/update/2');

    if (response.statusCode == 200) {
      print("Add Sub, Get SubList: Success!");
      return SubscriptionPost.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  List<Group> parseGroups(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Group>((json) => Group.fromJson(json)).toList();
  }

  Future<List<Group>> fetchGroups() async {
    var response;
    if (groups == null || updateGroup == true) {
      try {
        print("Will await.");
        response = await http.get('http://10.0.2.2:8000/addgroup').timeout(const Duration(seconds: 2));
      } on TimeoutException catch (_){
        print("Timeout.");
        Fluttertoast.showToast(msg: "Error: Failed to connect to server.");
      } on SocketException catch (_) {
        print("SocketException while putting.");
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
  }

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

  }

  _notNameless () async {
    var subscriptions = await fetchSubscriptions();
    var temp = [];
    print("here");
    for (var i = 0; i < subscriptions.groups.length; i++) {
      temp.add(subscriptions.groups[i]['name']);
    }
    for (var i = 0; i < _values.length; i++) {
      if (_values[i] == true) {
        temp.add(groups[i].name);
      }
    }
    String json = jsonEncode(SubscriptionPost(id: 2, email: 'testuser@test.com', groups: temp));
    print(json);
    await _makePutRequest(json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add a Subscription"),
        ),
        body: Column(children: [
          FutureBuilder(
            future: fetchGroups(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildRow(snapshot.data);
              }
              return CircularProgressIndicator();
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              onPressed: () async {
                await _notNameless();
                print("hello");
                Navigator.of(context).pop(() {
                  setState(() {});
                });
              },
              child: const Text('Add Subscriptions', style: TextStyle(fontSize: 20)),
              color: Colors.blue,
              textColor: Colors.white,
              elevation: 5,
            ),
          )
        ]));
  }

  Widget _buildRow(List _groups) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _groups.length,
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
}
