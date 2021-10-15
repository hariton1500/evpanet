import 'dart:convert';
import 'dart:ui';

import 'package:evpanet/Helpers/maindata.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Messages extends StatefulWidget {
  const Messages(
      {Key? key, required this.messagesStrings, required this.abonent})
      : super(key: key);

  final List<String> messagesStrings;
  final Abonent abonent;

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List<Map<String, dynamic>> messages = [];

  bool isShowFilters = false;
  List<bool>? filtersState;

  @override
  void initState() {
    //loadShared();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 246, 248, 1.0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
            iconTheme: const IconThemeData(
                color: const Color.fromRGBO(72, 95, 113, 1.0)),
            titleSpacing: 0.0,
            backgroundColor: const Color.fromRGBO(245, 246, 248, 1.0),
            title: Text(
              'Сообщения',
              style: const TextStyle(
                color: const Color.fromRGBO(72, 95, 113, 1.0),
                fontSize: 24.0,
              ),
            ),
            actions: [
              /*
              GestureDetector(
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 10.0),
                  child: const Icon(
                    //Icons.support_agent_outlined,
                    Icons.filter_alt_outlined,
                    color: const Color.fromRGBO(72, 95, 113, 1.0),
                    size: 24.0,
                  ),
                ),
                onTap: () {
                  setState(() {
                    isShowFilters = !isShowFilters;
                  });
                },
              ),
              */
            ]),
      ),
      body: !isShowFilters
          ? ListView.builder(
              itemCount: widget.messagesStrings.length,
              itemBuilder: (bc, index) {
                String _title =
                    jsonDecode(widget.messagesStrings[index])['title'];
                String _body =
                    jsonDecode(widget.messagesStrings[index])['message'];
                String _date =
                    jsonDecode(widget.messagesStrings[index])['timestamp'];
                //bool isFiltered;

                //filtersState!.forEach((state) { });
                return ListTile(
                    key: Key(index.toString()),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    tileColor: index.isEven ? Colors.white : Colors.white,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_date.split(' ')[0]),
                        Text(_date.split(' ')[1]),
                      ],
                    ),
                    leading: Icon(_title.contains('Мой EvpaNet')
                        ? Icons.question_answer_outlined
                        : Icons.warning_outlined),
                    title: Text(_title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        _body,
                        style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.blueGrey),
                      ),
                    ),
                    onLongPress: () => showDialog<bool>(
                            context: bc,
                            builder: (bc) => AlertDialog(
                                  content: Text('Удалить сообщение из списка?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          //print(index);
                                          Navigator.pop(bc, true);
                                        },
                                        child: Text('Да')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(bc, false);
                                        },
                                        child: Text('Нет')),
                                  ],
                                )).then((answer) {
                          if (answer ?? false) print(answer);
                        }));
              })
          : Filters(
              users: widget.abonent.users,
              onFiltersDone: (List<bool> filters) {
                filtersState = filters;
              },
            ),
    );
  }
}

class Filters extends StatefulWidget {
  const Filters({Key? key, required this.users, required this.onFiltersDone})
      : super(key: key);

  final List<User> users;
  final Function onFiltersDone;

  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  Map<int, bool> filterStates = {};

  @override
  void initState() {
    for (var i = 0; i < widget.users.length; i++) {
      filterStates[widget.users[i].id] = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.users.length,
        itemBuilder: (bc, index) {
          return Row(
            children: [
              Checkbox(
                  value: filterStates[widget.users[index].id],
                  onChanged: (state) {
                    setState(() {
                      filterStates[widget.users[index].id] = state!;
                      widget.onFiltersDone(filterStates);
                    });
                  }),
              TextButton(
                  onPressed: () => setState(() {
                        bool? temp = filterStates[widget.users[index].id];
                        filterStates[widget.users[index].id] = !temp!;
                      }),
                  child: Text(widget.users[index].id.toString()))
            ],
          );
        });
  }
}
