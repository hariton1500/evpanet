import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class CallWindowModal extends StatefulWidget {
  @override
  CallButtonWidget createState() => CallButtonWidget();
}

class CallButtonWidget extends State {
  String phoneToCall = '+79780489664';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              top: 18.0,
            ),
            margin: const EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(6.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        const Center(
                          child: Text(
                            "Пожалуйста выберите один из номеров технической поддержки.",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(72, 95, 113, 1.0),
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(6.0),
                        ),
                        DropdownButton<String>(
                            value: phoneToCall,
                            autofocus: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            onChanged: (newValue) {
                              setState(() {
                                phoneToCall = newValue!;
                              });
                            },
                            items: [
                              DropdownMenuItem(
                                  value: '+79780489664',
                                  child: Row(
                                    children: <Widget>[
                                      const Icon(Icons.phone_iphone),
                                      const SizedBox(width: 20.0),
                                      const Text('+7 (978) 048-96-64')
                                    ],
                                  )

                                  //child: Text('+7 (978) 048-96-64')
                                  ),
                              DropdownMenuItem(
                                  value: '+79780755900',
                                  child: Row(
                                    children: <Widget>[
                                      const Icon(Icons.phone_iphone),
                                      const SizedBox(width: 20.0),
                                      const Text('+7 (978) 075-59-00')
                                    ],
                                  )),
                            ]),
                      ],
                    )),
                const SizedBox(height: 24.0),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    decoration: BoxDecoration(
                      color: Color(0xff374b5d),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6.0),
                          bottomRight: Radius.circular(6.0)),
                    ),
                    child: const Text(
                      "Совершить звонок",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    //if (await canLaunch('tel://$phoneToCall'))
                      launch('tel://$phoneToCall');
                      Navigator.pop(context);
                  },
                )
              ],
            ),
          ),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Align(
                alignment: Alignment.topRight,
                child: const CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportMessageModal extends StatefulWidget {
  final Function onMessageSended;

  const SupportMessageModal({Key? key, required this.onMessageSended}) : super(key: key);
  
  @override
  _SupportMessageModalState createState() => _SupportMessageModalState();
}

class _SupportMessageModalState extends State<SupportMessageModal> {
  String text = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              top: 18.0,
            ),
            margin: EdgeInsets.only(top: 13.0, right: 8.0),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(6.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 0.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
                  alignment: Alignment.topCenter,
                  child: const Center(
                    child: Text(
                      'Отправка сообщения в службу технической поддержки',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color.fromRGBO(72, 95, 113, 1.0),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: TextField(
                    onChanged: (_text) {
                      text = _text;
                    },
                    autofocus: true,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      //hintText: "Напишите нам",
                      labelText: "Ваше сообщение",
                      labelStyle: const TextStyle(
                        color: Color(0xff374b5d),
                        letterSpacing: 1,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Color(0xff374b5d),
                          style: BorderStyle.solid,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.amber,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    decoration: BoxDecoration(
                      color: Color(0xff374b5d),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6.0),
                          bottomRight: Radius.circular(6.0)),
                    ),
                    child: const Text(
                      "Отправить сообщение",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    widget.onMessageSended(text);
                    Navigator.pop(context);
                    //_sendMessagePressed();
                  },
                )
              ],
            ),
          ),
          Positioned(
            right: 0.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Align(
                alignment: Alignment.topRight,
                child: const CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessagePressed() async {
     
    /*
    String answer =
        await RestAPI().remontAddPOST(text, guids[currentGuidIndex], devKey);
    dprintL(answer);
    Pushes _pushes = Pushes();
    _pushes.loadSavedPushes().then((value) {
      OneNotification _push = OneNotification();
      int id = int.parse(users[currentGuidIndex]['id']);
      _push.id = id;
      _push.title = '($id) Сообщение в службу поддержки';
      _push.body = text;
      _push.date = DateTime.now().toLocal().toString();
      _push.seen = false;
      _pushes.pushes.add(_push);
      _pushes.savePushes();
    });
    */
    Fluttertoast.showToast(
        msg: 'answer. В случае ответа Вы получите уведомление.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 15,
        webShowClose: true,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
    Navigator.pop(context);
  }
}
