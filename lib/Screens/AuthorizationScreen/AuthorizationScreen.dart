import 'package:evpanet/globals.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'inputs.dart';

class AuthorizationScreen extends StatelessWidget {
  final String token;

  const AuthorizationScreen({Key? key, required this.mode, required this.token})
      : super(key: key);
  final String mode;
  final String assetName = 'assets/images/splash_logo.png';

  @override
  Widget build(BuildContext context) {
    printLog('[{AuthorizationScreen}[build]');
    printLog('token is: $token');
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 1.2,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Color(0xff11273c), Color(0xff3c5d7c)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 20.0, bottom: 0),
              child: Column(
                children: [
                  Inputs(
                    mode: mode,
                    token: token,
                  ),
                  connectRequest(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /*
  Widget logoTop() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Image.asset(
          assetName,
          color: Color(0xffd3edff),
        ),
      ),
    );
  }*/

  Widget connectRequest(BuildContext buildContext) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8.0,
        //bottom: 8.0,
        right: 20.0,
        left: 20.0,
      ),
      child: TextButton(
        //elevation: 0.0,
        onPressed: () {
          launchUrl(
              Uri.parse('https://evpanet.com/internet/leave-a-statement.html'));
        },
        style: TextButton.styleFrom(foregroundColor: Color(0x408eaac2)),
        //color: Color(0x408eaac2),
        child: Center(
          //padding: EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(
                Icons.person_add,
                color: Colors.white,
              ),
              Text(
                'Оставить заявку на подключение',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
