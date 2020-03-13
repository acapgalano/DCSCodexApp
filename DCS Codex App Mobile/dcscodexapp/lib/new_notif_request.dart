import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'dart:convert';
import 'package:dcscodexapp/sublist.dart';


class NewNotificationRequestPost {
  final int user;
  final String group ;
  final String title;
  final String message;
  final String purpose;
  final String datetime;
  final bool approved;
  final bool viewed;

  NewNotificationRequestPost({this.user, this.group, this.title, this.message, this.purpose, this.datetime, this.approved, this.viewed});

  factory NewNotificationRequestPost.fromJson(Map<String, dynamic> json) {
    return NewNotificationRequestPost(
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
    'date_to_send': datetime,
    'approved': approved,
    'viewed': viewed,
  };
}

class NewNotificationRequestRoute extends StatefulWidget {
  static String tag = 'Request-page';
  @override
  _NewNotificationRequestState createState() => _NewNotificationRequestState();
}

class _NewNotificationRequestState extends State<NewNotificationRequestRoute> {
  DateTime _initialDate = new DateTime.now();
  TimeOfDay _initialTime = new TimeOfDay.now();
  final titleController = TextEditingController();
  final groupController = TextEditingController();
  final messageController = TextEditingController();
  final purposeController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  bool _groupValidate = false;
  bool _titleValidate = false;
  bool _messageValidate = false;
  bool _purposeValidate = false;
  String time;
  String date;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    groupController.dispose();
    messageController.dispose();
    purposeController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<SubscriptionPost> fetchSubscriptions() async {
    var response; // to contain response from the server
    try {
      print("Will await GET request.");
      //make GET request for Subscription list, await til timeout
      response = await http
          .get('http://10.0.2.2:8000/update/2/')
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

  _makePostRequest(String json) async {
    // set up POST request arguments
    String url = 'http://10.0.2.2:8000/createnotifrequest/';
    Map<String, String> headers = {"Content-type": "application/json"};
    var response;
    try {
      print("Will await GET request.");
      // make POST request
      response = await http.post(url, headers: headers, body: json).timeout(const Duration(seconds: 10));
    } on TimeoutException catch (_) {
      print("Timeout from GET request.");
      Fluttertoast.showToast(msg: "Error: Failed to reached server.");
    } on SocketException catch (_) {
      print("SocketException while putting.");
      Fluttertoast.showToast(msg: "Error: Failed to connect to server.");
    }
    // check the status code for the result
    int statusCode = response.statusCode;

    // this API passes back the updated item with the id added
    setState(() {
      print(response.body);
    });

    if (statusCode == 200 ||statusCode ==  201) {
      Fluttertoast.showToast(msg: "Successfully sent notification request.");
    }
  }

  Future<Null> _selectDate() async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: new DateTime(2000),
      lastDate: new DateTime(2050)
    );

    if(picked != null && picked != _initialDate){
      print('Date selected: ${_initialDate.toString()}');
      setState(() {
        _initialDate = picked;
      });
      date = "${picked.year.toString()}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}T";
    }
  }

  Future<Null> _selectTime() async {
    final TimeOfDay picked = await showTimePicker(
      context: context, 
      initialTime: _initialTime
    );

    if(picked != null && picked != _initialTime){
      print('Time selected: ${_initialTime.toString()}');
      setState(() {
        _initialTime = picked;
      });
      time = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00+08:00";
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: new AppBar(
        leading: new Icon(Icons.list),
        title: new Text("New Notification Request"),
        backgroundColor: Color(0xff800000),
      ),
      body: SingleChildScrollView(
        child: new Container(
          padding: new EdgeInsets.all(10.0),
          child: new Column(
            children: <Widget>[
              new TextField(
                controller: groupController,
                decoration: new InputDecoration(
                  errorText: _groupValidate ? 'Value Can\'t Be Empty' : null,
                  hintText: "Target Recipients",
                  labelText: "Target Recipients",
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(20.0)
                  )
                ),
              ),
              new Padding(padding: new EdgeInsets.only(top: 20.0),),
              new TextField(
                controller: titleController,
                decoration: new InputDecoration(
                  errorText: _titleValidate ? 'Value Can\'t Be Empty' : null,
                  hintText: "Title",
                  labelText: "Title",
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(20.0)
                  )
                ),
              ),
              new Padding(padding: new EdgeInsets.only(top: 20.0),),
              new TextField(
                controller: messageController,
                maxLines: 3,
                decoration: new InputDecoration(
                  errorText: _messageValidate ? 'Value Can\'t Be Empty' : null,
                  hintText: "Message",
                  labelText: "Message",
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(20.0)
                  )
                ),
              ),
              new Padding(padding: new EdgeInsets.only(top: 20.0),),
              new TextField(
                controller: purposeController,
                maxLines: 3,
                decoration: new InputDecoration(
                  errorText: _purposeValidate ? 'Value Can\'t Be Empty' : null,
                  hintText: "Purpose",
                  labelText: "Purpose",
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(20.0)
                  )
                ),
              ),
              new Padding(padding: new EdgeInsets.only(top: 20.0),),
              new Row(
                children: <Widget>[
                  new Text('Target: '),
                  new Padding(padding: new EdgeInsets.only(left: 20.0),),
                  new RaisedButton(
                    child: new Text('Date'),
                    onPressed: (){_selectDate();}
                  ),
                  new Padding(padding: new EdgeInsets.only(left: 20.0),),
                  new RaisedButton(
                    child: new Text('Time'),
                    onPressed: (){_selectTime();}
                  ),
                ],
              ),
              new Text('Date selected: ${_initialDate.toString()}'),
              new Text('Time selected: ${_initialTime.toString()}'),
              new Padding(padding: new EdgeInsets.only(top: 20.0),),
              new Row(
                children: <Widget>[
                  new Padding(padding: new EdgeInsets.only(left: 30.0),),
                  new RaisedButton(
                    child: new Text('Submit'),
                    onPressed: () async {
                      print("Clicked");
                      print(_groupValidate||_titleValidate||_messageValidate||_purposeValidate);
                      print(dateController.text+timeController.text);
                      setState(() {
                        groupController.text.isEmpty ? _groupValidate = true : _groupValidate = false;
                        titleController.text.isEmpty ? _titleValidate = true : _titleValidate = false;
                        messageController.text.isEmpty ? _messageValidate = true : _messageValidate = false;
                        purposeController.text.isEmpty ? _purposeValidate = true : _purposeValidate = false;
                      });
                      if(_groupValidate||_titleValidate||_messageValidate||_purposeValidate){
                        print("Error: Empty!");
                      }else{
                        String json = jsonEncode(NewNotificationRequestPost(
                            user: 2,
                            group: groupController.text,
                            title: titleController.text,
                            message: messageController.text,
                            purpose: purposeController.text,
                            datetime: date+time,
                            viewed: false,
                            approved: false));
                        print(json);
                        //Send updated user content to server through OUT request
                        await _makePostRequest(json);
                        Navigator.of(context).pop(() {
                          setState(() {});
                        });
                      }
                    }
                  ),
                  new Padding(padding: new EdgeInsets.only(left: 110.0),),
                  new RaisedButton(
                    child: new Text('Cancel'),
                    onPressed: (){
                      Navigator.of(context).pop(() {
                        setState(() {});
                      });
                    }
                  ),
                ],
              ),
              new Padding(padding: new EdgeInsets.only(top: 100.0),),
            ],
          ),
        ),
      ),
    );
  }
}