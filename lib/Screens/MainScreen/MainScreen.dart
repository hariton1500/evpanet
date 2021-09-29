import 'package:evpanet/Helpers/maindata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  final Abonent abonent;

  const MainScreen({ Key? key, required this.abonent }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromRGBO(245, 246, 248, 1.0),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Color.fromRGBO(72, 95, 113, 1.0)
          ),
          titleSpacing: 0.0,
          backgroundColor: Color.fromRGBO(245, 246, 248, 1.0),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Информация',
                style: TextStyle(
                  color: Color.fromRGBO(72, 95, 113, 1.0),
                  fontSize: 24.0,
                ),
              ),
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: TextStyle(
                  color: Color.fromRGBO(146, 152, 166, 1.0),
                  fontSize: 14.0
                ),
              )
            ],
          ),
          elevation: 0.0,
          actions: [

          ],
        ),
      ),
      body: Center(
        child: Text(widget.abonent.guids.toString()),
      ),
    );
  }
}