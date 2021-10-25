import 'dart:async';
import 'package:evpanet/Helpers/maindata.dart';
import 'package:flutter/material.dart';
import 'AuthorizationScreen/AuthorizationScreen.dart';
import 'MainScreen/MainScreen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late bool isAuthorised;

  @override
  void initState() {
    print('{StartScreen}[initState]');
    // проверка на флаг авторизованности
    loadShared();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('[{StartScreen}[build]');
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff11273c), Color(0xff3c5d7c)])),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Image.asset('assets/images/splash_logo.png'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 20.0, left: 24.0, right: 24.0, bottom: 16.0),
                      child: LinearProgressIndicator(
                        value: 1,
                        backgroundColor: Color(0xff3c5d7c),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Text(
                      'Загрузка...',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.white),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> loadShared() async {
    Abonent abonent = Abonent();
    await abonent.loadSavedData();
    isAuthorised = abonent.guids.isNotEmpty;
    //isAuthorised = false;
    if (!isAuthorised) {
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => AuthorizationScreen(
                  mode: 'new',
                )));
      });
    } else {
      Timer(Duration(seconds: 2), () async {
        //Abonent abonent = Abonent();
        //await abonent.loadSavedData();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
      });
    }
  }
}
