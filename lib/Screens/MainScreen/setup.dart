import 'package:evpanet/Helpers/maindata.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Setup extends StatefulWidget {
  const Setup({Key? key, required this.user, required this.index})
      : super(key: key);
  final User user;
  final int index;

  @override
  _SetupState createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  Abonent abonent = Abonent();
  User _user = User();
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
        Divider(
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
        Container(
          padding: const EdgeInsets.only(top: 10.0, right: 16.0, left: 16.0),
          child: Column(
            children: [],
          ),
        )
      ],
    );
  }

  void onChangeAutoactivation(bool value) async {
    //print('abonent.users[].auto before: ${abonent.users[widget.index].auto}');
    await abonent.changeSwitchParameters(type: 'auto', guid: widget.user.guid);
    //print('abonent.users[].auto after: ${abonent.users[widget.index].auto}');
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
