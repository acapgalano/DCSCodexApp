import 'package:flutter/material.dart';
import 'sublist.dart';


void main() {
  runApp(DCSCodexApp());
}

/// This widget is the root of our application.
///
/// The first screen we see is a list [Categories], each of which
/// has a list of [Unit]s.
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