import 'package:evpanet/Helpers/maindata.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Accounts extends StatefulWidget {
  const Accounts({Key? key, required this.abonent, required this.callback})
      : super(key: key);
  final Abonent abonent;
  final Function callback;

  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ReorderableListView.builder(
          header: ListTile(title: Text('Список учетных записей:')),
          itemBuilder: (context, index) {
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
              widget.abonent.users.insert(newIndex, _user);
            });
          }),
    );
  }
}
