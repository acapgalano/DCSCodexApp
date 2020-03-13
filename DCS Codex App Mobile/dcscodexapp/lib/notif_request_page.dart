import 'package:dcscodexapp/main_drawer.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:dcscodexapp/new_notif_request.dart';


class NotificationRequestPost {
  final int user;
  final String group ;
  final String title;
  final String message;
  final String purpose;
  final String datetime;
  final bool approved;
  final bool viewed;

  NotificationRequestPost({this.user, this.group, this.title, this.message, this.purpose, this.datetime, this.approved, this.viewed});

  factory NotificationRequestPost.fromJson(Map<String, dynamic> json) {
    return NotificationRequestPost(
      user: json['user'],
      group: json['group'],
      title: json['title'],
      message: json['message'],
      purpose: json['purpose'],
      datetime: json['datetime'],
      approved: json['approved'],
      viewed: json['viewed'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user,
    'group': group,
    'title': title,
    'message': message,
    'purpose': purpose,
    'datetime': datetime,
    'approved': approved,
    'viewed': viewed,
  };
}


class NotificationRequestPageRoute extends StatefulWidget {
  @override
  _NotificationRequestPageState createState() => _NotificationRequestPageState();
}

class _NotificationRequestPageState extends State<NotificationRequestPageRoute> {

  Future<List<NotificationRequestPost>> _fetchNotificationRequests() async {
    var response; // to contain response from the server
    try {
      print("Will await GET request.");
      //make GET request for Subscription list, await til timeout
      response = await http
          .get('http://10.0.2.2:8000/notifrequests/2')
          .timeout(const Duration(seconds: 10));
    } on TimeoutException catch (_) {
      print("Timeout from GET request.");
      Fluttertoast.showToast(msg: "Error: Failed to reached server.");
    } on SocketException catch (_) {
      print("SocketException while putting.");
      Fluttertoast.showToast(msg: "Error: Failed to connect to server.");
    }
    List<NotificationRequestPost>requests = [];
    if (response.statusCode == 200) {
      print("Success, Notification Requests received!");
      //print(json.decode(response.body));
      var received = json.decode(response.body);
      for(var request in received){
        print(request);
        requests.add(NotificationRequestPost.fromJson(request));
      }
    }
    return requests;
  }

  DataCell _checkStatus(element){
    if(element.approved){
      print("Approved!");
      return DataCell(Text('Approved by admin'));
    }else if(element.viewed){
      return DataCell(Text('Rejected by admin'));
    }else{
      return DataCell(Text('Pending'));
    }
  }

  Widget _buildTable(List _requests){
    return DataTable(
      columns: [
        DataColumn(label: Text('Title')),
        DataColumn(label: Text('Group')),
        DataColumn(label: Text('Status')),
      ],
      rows:
      _requests // Loops through dataColumnText, each iteration assigning the value to element
          .map(
        ((element) => DataRow(
          cells: <DataCell>[
            DataCell(Text(element.title)), //Extracting from Map element the value
            DataCell(Text(element.group)),
            _checkStatus(element),
          ],
        )),
      )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Notification Requests'),
        backgroundColor: Colors.red[900],
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future: _fetchNotificationRequests(),
        builder:
            (BuildContext context, AsyncSnapshot<List<NotificationRequestPost>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print('error: '+ snapshot.error.toString());
              print('snapshot:' + snapshot.data.toString());
              if (snapshot.hasData) {
                print('Enters future builder!');
                return _buildTable(snapshot.data);
              } else {
                print('error: '+ snapshot.error.toString());
                return Text('No notification requests to display.');
              }
            }else{
              print('error: '+ snapshot.error.toString());
              return CircularProgressIndicator();
            }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Button that leads to Create New Notification Request
        backgroundColor: Colors.red[900],
        child: Icon(Icons.send, color: Colors.white),
        onPressed: () {
          // Move to Add Subscription Route
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewNotificationRequestRoute()),
          );
        },
      ),
    );
  }
}