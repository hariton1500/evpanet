import 'dart:async';
import 'package:evpanet/Helpers/maindata.dart';
import 'package:flutter/material.dart';
import 'AuthorizationScreen/AuthorizationScreen.dart';
import 'MainScreen/MainScreen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key, required this.token}) : super(key: key);
  final String token;

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
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
                    Clipboard.setData(ClipboardData(text: widget.token));
                  },
                  child: Text(
                      ', google token: ${widget.token.substring(0, 10)}',
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
    await abonent.loadSavedData(widget.token);
    isAuthorised = abonent.guids.isNotEmpty;
    //isAuthorised = false;
    if (!isAuthorised) {
      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => AuthorizationScreen(
                  mode: 'new',
                  token: widget.token,
                )));
      });
    } else {
      Timer(Duration(seconds: 2), () async {
        //Abonent abonent = Abonent();
        //await abonent.loadSavedData();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) =>
                MainScreen(token: widget.token)));
      });
    }
  }
}
