import 'package:evpanet/Helpers/maindata.dart';
import 'package:evpanet/Screens/MainScreen/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Inputs extends StatefulWidget {
  final String mode;

  final String token;

  const Inputs({Key? key, required this.mode, required this.token})
      : super(key: key);
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
  String device = '';
  String inputPhone = '', inputId = '';
  bool enterButtonEnable = false, isSmall = false;

  @override
  void initState() {
    if (widget.mode == 'add') textRepresentationOfMode = 'Вход   ';
    if (widget.mode == 'new') textRepresentationOfMode = 'Вход   ';
    loadShareds();
    super.initState();
  }

  Widget logoTop() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          width: isSmall
              ? MediaQuery.of(context).size.width / 4
              : MediaQuery.of(context).size.width,
          child: Image.asset(
            'assets/images/splash_logo.png',
            color: Color(0xffd3edff),
            //height: logoHeight,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        logoTop(),
        Center(
          child: Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                  child: Column(
                children: [
                  TextFormField(
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
                    onTap: () => setState(() {
                      isSmall = true;
                    }),
                    onFieldSubmitted: (s) => setState(() {
                      isSmall = false;
                    }),
                  ),
                  TextFormField(
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
                    onTap: () => setState(() {
                      isSmall = true;
                    }),
                    onFieldSubmitted: (s) => setState(() {
                      isSmall = false;
                    }),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: widget.mode == 'add'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Color(0xff95abbf))),
                                      elevation: 0.0,
                                      primary: Color(0x858eaac2)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          '   Отмена',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Color(0xff95abbf))),
                                      elevation: 0.0,
                                      primary: Color(0x858eaac2)),
                                  onPressed: enterButtonEnable
                                      ? authorizationButtonPressed
                                      : null,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          textRepresentationOfMode,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0),
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ])
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Color(0xff95abbf))),
                                elevation: 0.0,
                                primary: Color(0x858eaac2)),
                            onPressed: enterButtonEnable
                                ? authorizationButtonPressed
                                : null,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    textRepresentationOfMode,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20.0),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              )),
            ),
          ),
        ),
      ],
    );
  }

  void checkInputs() {
    if (inputId != '' && inputPhone.length == 18)
      setState(() {
        enterButtonEnable = true;
      });
    else
      setState(() {
        enterButtonEnable = false;
      });
  }

  void loadShareds() {
    //SharedPreferences preferences = await SharedPreferences.getInstance();
    device = widget.token;
    if (device == '') {
      setState(() {
        enterButtonEnable = false;
      });
    }
    print('[input] $device');
  }

  void authorizationButtonPressed() async {
    setState(() {
      isSmall = false;
    });
    //print('[authorizationButtonPressed]');
    await abonent.loadSavedData(widget.token);
    print('trying to authorize with token: $device');
    await abonent.authorize(
        mode: widget.mode,
        number: '+${phone.getUnmaskedText()}',
        uid: int.tryParse(id.getUnmaskedText()) ?? 0,
        token: device);
    print(
        '[${widget.mode} abonent] (${abonent.lastApiErrorStatus}) ${abonent.lastApiMessage}');
    if (abonent.lastApiErrorStatus) {
      Fluttertoast.showToast(
          msg: abonent.lastApiMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    if (abonent.guids.length > 0) {
      abonent.saveGuidsList();
      //можно уходить на главный экран
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => MainScreen(token: device)));
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
