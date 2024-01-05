
import 'package:evpanet/globals.dart';
import 'package:flutter/material.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({Key? key}) : super(key: key);
  

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Text(logs),
      ),
    );
  }
}