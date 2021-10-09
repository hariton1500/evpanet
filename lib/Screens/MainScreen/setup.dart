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
        /*
        _user.auto ? Card(
          color: Colors.cyan,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: const ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            title: const Text(
              'Чтобы изменить тарифный план, необходимо отключить автоактивацию.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              ),
            ),
          ),
        ) :
        Container(
          padding: const EdgeInsets.only(top: 10.0, right: 16.0, left: 16.0),
          child: Column(
            children: [],
          ),
        )
        */
      ],
    );
  }

  Widget tarifsChange() {
    bool isCanChangeTarif = _user.tarifs.any((element) {
      print('allowed_tarif:');
      print(int.parse(element['sum'].toString()));
      print(_user.balance);
      return int.parse(element['sum'].toString()) < _user.balance;
      }
    );
    print(isCanChangeTarif);
    if (_user.auto) return Card(
          color: Colors.cyan,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: const ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            title: const Text(
              'Чтобы изменить тарифный план, необходимо отключить автоактивацию.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              ),
            ),
          ),
        ); else if (!isCanChangeTarif) return Card(
          color: Colors.cyan,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: const ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            title: const Text(
              'На Вашем счету недостаточно средств для активации тарифного плана.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              ),
            ),
          ),
        ); else return Column(
          children: List.generate(_user.tarifs.length, (index) {return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: RadioListTile<String>(
              activeColor: Colors.green,
              dense: true,
              title: Text(_user.tarifs[index]['name']),
              subtitle: _user.tarifSum == _user.tarifs[index]['sum'] ? Text('(текущий тариф)') : null,
              value: _user.tarifs[index]['id'],
              groupValue: '',
              onChanged: _user.tarifs[index]['sum'] <= _user.balance ? (index){} : null
              ),
          );}),
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
