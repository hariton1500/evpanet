import 'package:evpanet/Helpers/maindata.dart';
import 'package:evpanet/Screens/MainScreen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Inputs extends StatefulWidget {
  @override
  _InputsState createState() => _InputsState();
}

class _InputsState extends State<Inputs> {
  //String editPhone;
  MaskTextInputFormatter phone = MaskTextInputFormatter(
      mask: '+# (###) ###-##-##', filter: {"#": RegExp(r'[0-9]')});
  //int editID;
  MaskTextInputFormatter id =
      MaskTextInputFormatter(mask: '#####', filter: {"#": RegExp(r'[0-9]')});
  String textRepresentationOfMode = 'Вход   ';
  Abonent abonent = Abonent();
  late String device;
  String inputPhone = '', inputId = '';
  bool enterButtonEnable = false;

  @override
  void initState() {
    loadShareds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
              child: Column(
            children: [
              TextFormField(
                //onChanged: (textPhone) => editPhone = textPhone,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: Color(0xffd3edff), fontSize: 18.0),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                    labelText: 'Номер телефона',
                    labelStyle: TextStyle(
                      color: Color(0xffd3edff),
                      letterSpacing: 1,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffd3edff))),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffd3edff)))),
                inputFormatters: [phone],
                onChanged: (text) {
                  inputPhone = text;
                  checkInputs();
                },
              ),
              TextFormField(
                //onChanged: (textID) => editID = int.parse(textID),
                keyboardType: TextInputType.phone,
                style: TextStyle(color: Color(0xffd3edff), fontSize: 18.0),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                    labelText: 'Ваш ИД (ID)',
                    labelStyle: TextStyle(
                      color: Color(0xffd3edff),
                      letterSpacing: 1,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffd3edff))),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffd3edff)))),
                inputFormatters: [id],
                onChanged: (text) {
                  inputId = text;
                  checkInputs();
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xff95abbf))),
                      elevation: 0.0,
                      primary: Color(0x858eaac2)),
                  //shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xff95abbf))),
                  //elevation: 0.0,
                  //color: Color(0x858eaac2),
                  onPressed: enterButtonEnable ? authorizationButtonPressed : null,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textRepresentationOfMode,
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
        ),
      ),
    );
  }

  void checkInputs() {
    print('[$inputPhone][$inputId]');
    if (inputId != '' && inputPhone.length == 18) setState(() {
      enterButtonEnable = true;
    }); else setState(() {
      enterButtonEnable = false;
    });
  }
  
  Future<void> loadShareds() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    device = preferences.getString('deviceId') ?? '';
  }

  void authorizationButtonPressed() async {
    //print('$editPhone:$editID');
    print('${phone.getUnmaskedText()}:${id.getUnmaskedText()}');
    await abonent.authorize(
        number: '+${phone.getUnmaskedText()}',
        uid: int.tryParse(id.getUnmaskedText()) ?? 0,
        token: device);
    print(abonent.lastApiMessage);
    print(abonent.lastApiErrorStatus);
    if (abonent.lastApiErrorStatus) {
      Fluttertoast.showToast(
        msg: abonent.lastApiMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
    if (abonent.guids.length > 0) {
      //можно уходить на главный экран
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => MainScreen(abonent: abonent,)));
    }
  }
}

class ProgressIndicatorWidget extends StatefulWidget {
  @override
  _ProgressIndicatorWidgetState createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: LinearProgressIndicator(
          value: 1, //currentGuidIndex / (guids.isNotEmpty ? guids.length : 1),
          backgroundColor: Color(0xff3c5d7c),
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
    );
  }
}
