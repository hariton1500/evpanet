import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'inputs.dart';

class AuthorizationScreen extends StatelessWidget {
  const AuthorizationScreen({Key? key, required this.mode}) : super(key: key);
  final String mode;
  final String assetName = 'assets/images/splash_logo.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        backgroundColor: Color(0xff3c5d7c),
      ),*/
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
  }

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
          launch('https://evpanet.com/internet/leave-a-statement.html');
          //Navigator.of(buildContext).push(MaterialPageRoute(builder: (BuildContext context) => OrderView()));
        },
        style: TextButton.styleFrom(primary: Color(0x408eaac2)),
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
                '???????????????? ???????????? ???? ??????????????????????',
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
