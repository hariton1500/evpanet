import 'dart:io';

import 'package:evpanet/Helpers/maindata.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Setup extends StatefulWidget {
  const Setup(
      {Key? key,
      required this.user,
      required this.index,
      required this.onSetupChanged})
      : super(key: key);
  final User user;
  final int index;
  final VoidCallback onSetupChanged;

  @override
  _SetupState createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  Abonent abonent = Abonent();
  User _user = User();
  double daysToAdd = 1;
  //late int currentUserIndex;

  @override
  void initState() {
    start();
    //currentUserIndex = abonent.users.indexWhere((user) => user.guid == widget.user.guid);
    super.initState();
  }

  void start() async {
    _user = widget.user;
    print(_user.auto);
    await abonent.loadSavedData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
              top: 16.0, left: 16.0, right: 16.0, bottom: 10.0),
          child: Column(
            children: [
              SwitchListTile(
                  activeColor: Color(0xff3e6282),
                  dense: true,
                  value: _user.auto, //abonent.users[widget.index].auto,
                  title: const Text(
                    'Автоактивация пакета',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onChanged: onChangeAutoactivation),
              SwitchListTile(
                  activeColor: const Color(0xff3e6282),
                  dense: true,
                  value: _user
                      .parentControl, //abonent.users[widget.index].parentControl,
                  title: const Text(
                    'Родительский контроль',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onChanged: onChangeParentControl),
            ],
          ),
        ),
        const Divider(
          indent: 20.0,
          endIndent: 20.0,
          color: const Color(0xff3e6282),
        ),
        Container(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: const Text(
              'Доступные тарифные планы',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: const Color.fromRGBO(72, 95, 113, 1.0),
                  fontWeight: FontWeight.bold),
            )),
        tarifsChange(),
        const Divider(
          indent: 20.0,
          endIndent: 20.0,
          color: const Color(0xff3e6282),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
          child: Column(
            children: [
              Text(
                'Добавление дней к текущему пакету',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    color: const Color.fromRGBO(72, 95, 113, 1.0),
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                child: Text(
                  'Стоимость одного дня - ${_user.dayPrice} руб.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Text(
                'Текущее количество дней: ${_user.daysRemain}',
                style: TextStyle(fontSize: 16),
              ),
              _user.balance >= _user.dayPrice
                  ? Column(
                      children: [
                        Slider(
                          value: daysToAdd,
                          onChanged: (days) => setState(() {
                            daysToAdd = days.roundToDouble();
                          }),
                          min: 1,
                          max: (_user.balance / _user.dayPrice).floorToDouble(),
                          divisions: (_user.balance / _user.dayPrice).floor(),
                          label: daysToAdd.toString(),
                          activeColor: const Color(0xff3e6282),
                          inactiveColor: const Color(0xff939faa),
                        ),
                        ElevatedButton(
                            onPressed: () => Platform.isAndroid ? showDialog(
                                context: context,
                                builder: (bc) => AlertDialog(
                                      content: Text(
                                          'Добавить ${daysToAdd.toInt()} дн?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              //print(id);
                                              await abonent.addDays(
                                                  days: daysToAdd.round(),
                                                  guid: _user.guid);
                                              widget.onSetupChanged();
                                              Navigator.pop(context);
                                              setState(() {
                                                if (!abonent.lastApiErrorStatus)
                                                  _user.daysRemain +=
                                                      daysToAdd.round();
                                              });
                                            },
                                            child: Text('Да')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Нет'))
                                      ],
                                    )) : showCupertinoDialog(
                                context: context,
                                builder: (bc) => CupertinoAlertDialog(
                                      content: Text(
                                          'Добавить ${daysToAdd.toInt()} дн?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              //print(id);
                                              await abonent.addDays(
                                                  days: daysToAdd.round(),
                                                  guid: _user.guid);
                                              widget.onSetupChanged();
                                              Navigator.pop(context);
                                              setState(() {
                                                if (!abonent.lastApiErrorStatus)
                                                  _user.daysRemain +=
                                                      daysToAdd.round();
                                              });
                                            },
                                            child: Text('Да')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Нет'))
                                      ],
                                    )),
                            style: ElevatedButton.styleFrom(
                                onPrimary: Colors.white,
                                padding: const EdgeInsets.all(0.0)),
                            child: Container(
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Color.fromRGBO(68, 98, 124, 1),
                                Color.fromRGBO(10, 33, 51, 1)
                              ])),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 64, vertical: 16),
                              child: Text(
                                'Добавить ${daysToAdd.round()} дн.',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ))
                      ],
                    )
                  : Card(
                      color: Colors.cyan,
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child: ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Недостаточно средств для добавления дней.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ))
            ],
          ),
        )
      ],
    );
  }

  Widget tarifsChange() {
    bool isCanChangeTarif = _user.tarifs.any((element) {
      //print('allowed_tarif:');
      //print(int.parse(element['sum'].toString()));
      //print(_user.balance);
      return int.parse(element['sum'].toString()) < _user.balance;
    });
    //print(isCanChangeTarif);
    if (_user.auto)
      return Card(
        color: Colors.cyan,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: const ListTile(
          leading: const Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          title: const Text(
            'Чтобы изменить тарифный план, необходимо отключить автоактивацию.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    else if (!isCanChangeTarif)
      return Card(
        color: Colors.cyan,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: const ListTile(
          leading: const Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          title: const Text(
            'На Вашем счету недостаточно средств для активации тарифного плана.',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    else
      return Column(
        children: List.generate(_user.tarifs.length, (index) {
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: RadioListTile<String>(
                  activeColor: Colors.green,
                  dense: true,
                  title: Text(_user.tarifs[index]['name']),
                  subtitle: _user.tarifSum == _user.tarifs[index]['sum']
                      ? Text('(текущий тариф)')
                      : null,
                  value: _user.tarifs[index]['id'],
                  groupValue: _user.tarifs.firstWhere(
                      (tarif) => tarif['sum'] == _user.tarifSum)['id'],
                  onChanged: (id) {
                    //tarif sum <= balance
                    if (_user.tarifs[index]['sum'] <= _user.balance) {
                      //if 200 or 300 Mb packets
                      if (_user.tarifs[index]['name']
                              .toString()
                              .contains('200') ||
                          _user.tarifs[index]['name']
                              .toString()
                              .contains('300')) {
                        showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  content: Container(
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    child: Column(
                                        children: [
                                          Text(
                                            'Вы выбрали тариф ${_user.tarifs[index]['name']}, который требует выполнить следующие условия:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Divider(),
                                          Text(
                                              '1. У Вас должен быть гигабитный роутер;',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic)),
                                          Text(
                                              '2. Нужно произвести переключение на нашем оборудовании;',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic)),
                                          Text(
                                              '3. В некоторых случаях провести к вам другой кабель;',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic)),
                                          Divider(),
                                          Text(
                                              'Оставить заявку на изменение тарифа?')
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text('Отмена')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text('Согласен')),
                                  ]);
                            }).then((answer) {
                          if ((answer ?? false)) {
                            //left zayavku na tarif 200 or 300
                            print('Sending message about packet 200 or 300');
                            abonent.postMessageToProvider(
                                message:
                                    'Сообщение от приложения: Пожелание перейти на тариф ${_user.tarifs[index]['name']}',
                                guid: _user.guid);
                            Fluttertoast.showToast(msg: abonent.lastApiMessage);
                            if (!abonent.lastApiErrorStatus) {
                              Map<String, dynamic> _message = {
                                'title':
                                    '(${_user.id}) Сообщение в службу поддержки',
                                'message': 'Заявка отправлена',
                                'timestamp':
                                    '${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}'
                              };
                              abonent.saveMessage(message: _message);
                              abonent.messages.add(_message);
                            }
                          }
                        });
                      } else {
                        showDialog(
                            context: context,
                            builder: (bc) => AlertDialog(
                                  content: Text('Изменить тариф?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          await abonent.changeTarif(
                                              tarifId: id!, guid: _user.guid);
                                          widget.onSetupChanged();
                                          Navigator.of(context).pop(true);
                                          setState(() {
                                            _user.tarifName = _user.tarifs
                                                    .firstWhere((element) =>
                                                        element['id'] ==
                                                        abonent.lastApiMessage)[
                                                'name'];
                                            _user.tarifSum = _user.tarifs
                                                .firstWhere((element) =>
                                                    element['id'] ==
                                                    abonent
                                                        .lastApiMessage)['sum'];
                                          });
                                        },
                                        child: Text('Да')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text('Нет'))
                                  ],
                                )) : showCupertinoDialog(context: context, builder: (bc) => CupertinoAlertDialog(
                                  content: Text('Изменить тариф?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () async {
                                          print(id);
                                          await abonent.changeTarif(
                                              tarifId: id!, guid: _user.guid);
                                          widget.onSetupChanged();
                                          Navigator.pop(context);
                                          setState(() {
                                            _user.tarifName = _user.tarifs
                                                    .firstWhere((element) =>
                                                        element['id'] ==
                                                        abonent.lastApiMessage)[
                                                'name'];
                                            _user.tarifSum = _user.tarifs
                                                .firstWhere((element) =>
                                                    element['id'] ==
                                                    abonent
                                                        .lastApiMessage)['sum'];
                                          });
                                        },
                                        child: Text('Да')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Нет'))
                                  ],
                                ));
                      }
                    }
                  }));
        }),
      );
  }

  //askToChangeTarifDialog() {}

  void onChangeAutoactivation(bool value) async {
    await abonent.changeSwitchParameters(type: 'auto', guid: widget.user.guid);
    setState(() {
      if (!abonent.lastApiErrorStatus)
        _user.auto = abonent.lastApiMessage == '1';
    });
  }

  void onChangeParentControl(bool value) async {
    await abonent.changeSwitchParameters(
        type: 'parent', guid: widget.user.guid);
    setState(() {});
  }
}
