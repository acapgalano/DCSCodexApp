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
Rog Isidro | 2/20/2020 -  Notification, NotificationListRoute, NotificationListRouteState, DetailPage
Anica Galano | 2/26/2020 - NotificationMessage, Edits to NotificationListRouteState, removed DetailPage

=================================================================
File Creation Date: February 20, 2020
Development Group: CS 192 WF-10v2 Group 5
Client Group: Asst. Prof. Ma. Rowena C. Solamo
Purpose of Software: The DCS Codex Notification System aims to add the elements of notifications
and groups to the existing DCS Codex System through a mobile app.

*/

import 'package:dcscodexapp/main_drawer.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Notification{
  final String title;
  final String info;
  final String group;
  final String datetime;

  Notification({this.title, this.info, this.group, this.datetime});

  factory Notification.fromJson(Map<String, dynamic> json){
    return Notification(
      title: json['title'],
      info: json['info'],
      group: json['group'],
      datetime: json['date_to_send']
    );
  }

}

class NotificationMessagePost {
  final int id;
  final Notification notification;
  final int user;
  final bool viewed;

  NotificationMessagePost({this.id, this.notification, this.user, this.viewed});

  factory NotificationMessagePost.fromJson(Map<String, dynamic> json)  {
    print("converting");
    return NotificationMessagePost(
      id: json['id'],
      notification: Notification.fromJson(json['notification']),
      user: json['user'],
      viewed: json['viewed']
    );
  }

  Map<String, dynamic> toJson() => {
    'notification': notification,
    'user': user,
    'viewed': viewed,
  };
}

class NotificationsListRoute extends StatefulWidget {
  static String tag = 'notifications-page';
  @override
  _NotificationsListRouteState createState() => _NotificationsListRouteState();
}

class _NotificationsListRouteState extends State<NotificationsListRoute> {

  Future<List<NotificationMessagePost>> _getNotifications() async {
    print("Requesting for notifs");
    var response =  await http.get("http://10.0.2.2:8000/notifs/2");
    var jsonData = json.decode(response.body);
    print("Notifs received");

    List<NotificationMessagePost> templist = [];

    for(var notification in jsonData){
      print(notification);
      NotificationMessagePost temp = NotificationMessagePost.fromJson(notification);
      print(temp);
      templist.add(temp);
    }

    print(templist.length);

    List<NotificationMessagePost> notifications = templist.reversed.toList();
    return notifications;
  }

  _makeDeleteRequest(int id) async{
    // make DELETE request
    var response = await http.delete('http://10.0.2.2:8000/notifmsg/${id.toString()}');
    // check the status code for the result
    int statusCode = response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Notifications'),
        backgroundColor: Colors.red[900],
      ),
      drawer: MainDrawer(),
      backgroundColor: Colors.white,
      body: Container(
        child: FutureBuilder(
          future: _getNotifications(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {

            if(snapshot.data == null){
              return Container(
                child: Center(
                  child: Text("Loading...")
                )
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.all(20.0),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    child: ListTile(
                      title: Text(snapshot.data[index].notification.title),
                      subtitle: Text(snapshot.data[index].notification.group),
                      onTap: () {
                        showDialog(context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context){
                          return Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            child: Container(
                                height:300.0,
                                width: 200.0,
                                color: Colors.grey[150],
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: Align(
                                        alignment: Alignment(1.05, -1.5),
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            ),
                                          )
                                        )
                                      )
                                    ),
                                    Container(
                                      child: Text(
                                          snapshot.data[index].notification.title,
                                          style: Theme.of(context).textTheme.headline
                                      )
                                    ),
                                    Container(
                                      color: Colors.grey[200],
                                      height: 1.50,
                                      width: 180.00,
                                    ),
                                    Container(
                                      child: Text(
                                          snapshot.data[index].notification.group,
                                          style: Theme.of(context).textTheme.subhead
                                      )
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(15.0),
                                      height: 200.00,
                                      width: 250.00,
                                      color: Colors.grey[200],
                                      child: Text(
                                          snapshot.data[index].notification.info,
                                          style: Theme.of(context).textTheme.body1,
                                      )
                                    )
                                  ],
                                ),
                            )
                          );
                        });
                        /*Navigator.push(context,
                          new MaterialPageRoute(builder: (context) => DetailPage(snapshot.data[index]))
                        );*/
                      },
                    ),
                    background: Container(
                      color: Colors.grey,
                    ),
                    key: ValueKey("dismiss notif"),
                    onDismissed: (direction) {
                      String title = snapshot.data[index].notification.title;
                      _makeDeleteRequest(snapshot.data[index].id);
                      (snapshot.data).removeAt(index);
                      Scaffold.of(context).showSnackBar(new SnackBar(
                        content: new Text('"$title" was dismissed.'),
                        ));
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
