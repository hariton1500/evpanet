import 'package:evpanet/Helpers/maindata.dart';
import 'package:evpanet/Screens/AuthorizationScreen/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'AuthorizationScreen/AuthorizationScreen.dart';

class Accounts extends StatefulWidget {
  const Accounts({Key? key, required this.abonent, required this.callback})
      : super(key: key);
  final Abonent abonent;
  final Function callback;

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {

  bool isShowInputs = false;

  @override
  Widget build(BuildContext context) {
    //print('===========');
    return Scaffold(
      appBar: AppBar(
            iconTheme: const IconThemeData(
                color: const Color.fromRGBO(72, 95, 113, 1.0)),
            titleSpacing: 0.0,
            backgroundColor: const Color.fromRGBO(245, 246, 248, 1.0),
            title: Text(
              'Учетные записи',
              style: const TextStyle(
                color: const Color.fromRGBO(72, 95, 113, 1.0),
                fontSize: 24.0,
              ),
            ),
        ),
      body: ReorderableListView.builder(
          header: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(onPressed: () {
                  setState(() {
                    widget.abonent.guids.clear();
                    widget.abonent.users.clear();
                    widget.abonent.saveData();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => AuthorizationScreen()));
                  });
                }, icon: Icon(Icons.delete_sweep_outlined), label: Text('Удалить все')),
                TextButton.icon(onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AuthorizationScreen()));
                }, icon: Icon(Icons.add_circle_outline), label: Text('Добавить новые')),
                Divider(),
              ],
            )
          ),
          itemBuilder: (context, index) {
            //print('[$index] ${widget.abonent.users[index].id}');
            //print('============');
            return ListTile(
              key: Key('user[$index]'),
              leading: Container(
                //borderRadius: BorderRadius.circular(5),
                //padding: EdgeInsets.only(top: 5),
                //alignment: Alignment.centerLeft,
                child: Text(
                  widget.abonent.users[index].id.toString(),
                  textAlign: TextAlign.end,
                ),
              ),
              title: Text(widget.abonent.users[index].name.toString()),
              trailing: IconButton(
                icon: Icon(Icons.delete_outlined),
                onPressed: () {
                  setState(() {
                    widget.abonent.users.removeAt(index);
                    widget.abonent.guids.removeAt(index);
                    widget.abonent.saveData();
                    if (widget.abonent.users.isEmpty) {Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => AuthorizationScreen()));}
                    //print('removing at $index');
                    //widget.abonent.users.forEach((element) {print(element.id);});
                    widget.callback();
                  });
                },
              ),
            );
          },
          itemCount: widget.abonent.users.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) newIndex -= 1;
              final User _user = widget.abonent.users.removeAt(oldIndex);
              final String _guid = widget.abonent.guids.removeAt(oldIndex);
              widget.abonent.users.insert(newIndex, _user);
              widget.abonent.guids.insert(newIndex, _guid);
              widget.abonent.saveData();
            });
          }),
    );
  }
}
