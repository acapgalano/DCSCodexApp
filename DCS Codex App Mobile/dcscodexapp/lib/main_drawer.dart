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
Rog Isidro | 2/20/2020 -  MainDrawer

=================================================================
File Creation Date: February 20, 2020
Development Group: CS 192 WF-10v2 Group 5
Client Group: Asst. Prof. Ma. Rowena C. Solamo
Purpose of Software: The DCS Codex Notification System aims to add the elements of notifications
and groups to the existing DCS Codex System through a mobile app.

*/

import 'package:flutter/material.dart';
import 'package:dcscodexapp/notifications_page.dart';
import 'package:dcscodexapp/sublist.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Colors.red[900],
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                  ),
                  Text(
                    'Rog Isidro',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text(
              'Calendar',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              /* Navigator.push(context, new MaterialPageRoute(
                builder: (context) =>
                new HomePage())
              );*/
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new NotificationsListRoute()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              'Subscriptions',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionListRoute(),
                  ));
            },
          ),
          ListTile(
            leading: Icon(Icons.arrow_back),
            title: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: null,
          ),
        ],
      ),
    );
  }
}
