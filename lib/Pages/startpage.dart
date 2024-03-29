import 'dart:async';
import 'package:evpanet/Helpers/maindata.dart';
import 'package:evpanet/Models/app.dart';
import 'package:evpanet/Screens/AuthorizationScreen/AuthorizationScreen.dart';
import 'package:evpanet/Screens/MainScreen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key, required this.appData}) : super(key: key);
  final AppData appData;

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late bool isAuthorised;
  String version = '', buildNumber = '';

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
      bottomSheet: Container(
          color: Color(0xff3c5d7c),
          child: Row(
            children: [
              Text(
                'Версия: $version',
                style: TextStyle(color: Colors.white30),
              ),
              TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.appData.token));
                  },
                  child: Text(
                      ', google token: ${widget.appData.token.substring(0, 10)}',
                      style: TextStyle(color: Colors.white30)))
            ],
          )),
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
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        version = value.version;
        buildNumber = value.buildNumber;
      });
    });
    Abonent abonent = Abonent();
    await abonent.loadSavedData(widget.appData.token);
    isAuthorised = abonent.guids.isNotEmpty;
    //isAuthorised = false;
    if (!isAuthorised) {
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => AuthorizationScreen(
                  mode: 'new',
                  token: widget.appData.token,
                )));
      });
    } else {
      Timer(Duration(seconds: 2), () async {
        //Abonent abonent = Abonent();
        //await abonent.loadSavedData();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) =>
                MainScreen(token: widget.appData.token)));
      });
    }
  }
}
